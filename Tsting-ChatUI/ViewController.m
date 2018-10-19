//
//  ViewController.m
//  Tsting-ChatUI
//
//  Created by bonlion on 2018/9/19.
//  Copyright © 2018 dasui. All rights reserved.
//

#import "ViewController.h"
#import "MarlServiceChatInputView.h"
#import "MarlChatKeyBoardView.h"
#import "MarlServiceChatCell.h"

CGFloat const lastCellBetweenBottom = 20.f;
CGFloat const minHeightOfCell = 60.f;

@interface ViewController ()<MarlChatKeyBoardDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

/** keyboard */
@property (nonatomic, strong) MarlChatKeyBoardView *keyBoardView;
/** table view */
@property (nonatomic, strong) UITableView *tableView;
/** data source */
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self addKeyBoardView];
    [self addTableView];
    
    
    [self addLeftBarButton];
}
// MARK: - delete button
- (void)addLeftBarButton
{
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(actionDelete) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.frame = CGRectMake(100, 100, 50, 50);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
}
- (void)actionDelete
{
    if (!self.dataSource.count) {
        return;
    }
    [self.dataSource removeObjectAtIndex:self.dataSource.count -1];
    [self.tableView reloadData];
}
// MARK: -
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottom];
}
// MARK: - add keyboard
- (void)addKeyBoardView
{

    _keyBoardView = [[MarlChatKeyBoardView alloc] initWithFrame:CGRectZero];
    _keyBoardView.backgroundColor = [UIColor redColor];
    //设置代理方法
    _keyBoardView.delegate = self;
    [self.view addSubview:_keyBoardView];
    
    [_keyBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
//        make.height.mas_equalTo(@(height));
        make.bottom.mas_equalTo(self.view).offset(IS_IPHONE_X ? -Safe_Bottom_Area : 0.f);
    }];
}
// MARK: - add tableView
- (void)addTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NaviHeight, self.view.width, self.view.height - self.keyBoardView.height - (IS_IPHONE_X ? Safe_Bottom_Area : 0.f) - NaviHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[MarlServiceChatCell class] forCellReuseIdentifier: MarlServiceChatCellID];
    //给UITableView添加手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [_tableView addGestureRecognizer:tapGesture];
    [self.view insertSubview:_tableView atIndex:0];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    //收回键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyBoardWillHiddenNotify object:nil];

    return YES;
}

// MARK: - keyboard delegate
- (void)keyboardChangedFrameWithMinY:(CGFloat)minY
{
    
    if (!self.dataSource.count) {
        return;
    }
    // 获取对应cell的rect值（其值针对于UITableView而言）
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    CGRect rect = [self.tableView rectForRowAtIndexPath:lastIndex];
    CGFloat lastMaxY = rect.origin.y + rect.size.height;

    
    if (lastMaxY <= self.tableView.height) {
        if (lastMaxY+NaviHeight >= minY) {
            
            // TODO: - 这里有问题！！！ 当last cell的maxY 刚好大于keyboard的Y时，tableview的底部会与keyboard分离(产生一个间距，猜测由于tableview的Y值计算错误引起。)
            // FIXME: - 9.25日测试真机未重现该问题。！！！又出现了

            /// 判断 如果最后一个cell的最大Y值与tableview的高度之差小于一个最小cell的高度时，直接让tableview的底部与输入框顶部对齐。
            // 补充：因为下一个的cell最大Y值已经超过高度，继续使用else内的公式，会导致tableview整体上移。故加此条件判断
            
            if (self.tableView.height - lastMaxY - lastCellBetweenBottom <= minHeightOfCell) {
                self.tableView.y = minY - self.tableView.height;
                return;
            }
            self.tableView.y = minY - lastMaxY - NaviHeight - lastCellBetweenBottom;
            //r 如果键盘弹出后，输入框的最小Y值 <= 最后一个cell的最大Y值，则保持最后一个cell始终处于输入框上方(保持可见).此时需要移动tableview Y值。
            
        } else {
            // 如果键盘弹出后，输入框的最小Y值 >= 最后一个cell的最大Y值(即输入框低于最后一个cell)，则tableview的Y值不变。
            self.tableView.contentInset = UIEdgeInsetsZero;
            self.tableView.y = NaviHeight;
        }
    } else {
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.y = minY - self.tableView.height;
    }

    [self scrollToBottom];
} 
- (void)keyboardSendMessage:(NSString *)textStr
{
    NSLog(@"send msg ->%@", textStr);
    [self.dataSource addObject:textStr];
    [self.tableView reloadData];
    [self scrollToBottom];
}
- (void)scrollToBottom {
    if (self.dataSource.count >= 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:MAX(0, self.dataSource.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
// MARK: - lazy load
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
//        for (int i = 0; i < 3; i++) {
//            [_dataSource addObject:@"我们要好好学习了。你的手机📱？我们的孩子都会在我们面前进行一场轰轰烈烈地爱过我爱我😊？我们的孩子都会很美好呢？我们的孩子都会"];
//        }
    }
    return _dataSource;
}

// MARK: - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MarlServiceChatCell *cell = [[MarlServiceChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MarlServiceChatCellID];

    cell.content = self.dataSource[indexPath.row];
    [cell setRoleType:(indexPath.row % 2)];
    return cell;
}
// MARK: - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:MarlServiceChatCellID cacheByIndexPath:indexPath configuration:^(MarlServiceChatCell *cell) {
        cell.content = self.dataSource[indexPath.row];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return lastCellBetweenBottom;
}


@end
