//
//  WBHistorySearchView.m
//  WeiBo
//
//  Created by JiangNan on 2022/5/13.
//

#import "WBHistorySearchView.h"
#import "WBHistorySearchModel.h"

@interface WBHistorySearchView()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong, readwrite) WBHistorySearchModel *searchModel;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *dataArray;
@property (nonatomic, strong, readwrite) UITableView *tableView;
@end

@implementation WBHistorySearchView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _searchModel = [WBHistorySearchModel shareInstance];
        _dataArray = _searchModel.historySearchMutableArray.copy;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(historySearchView:didSelectCellText:)]) {
        [self.delegate historySearchView:self didSelectCellText:self.dataArray[indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id123"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id123"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    cell.textLabel.alpha = 0.7;
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(historySearchViewWillBeginDragging:)]) {
        [self.delegate historySearchViewWillBeginDragging:self];
    }
}

#pragma mark - public method

- (void)readLoadHistory {
    self.dataArray = self.searchModel.historySearchMutableArray.copy;
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0, 0);
}

@end
