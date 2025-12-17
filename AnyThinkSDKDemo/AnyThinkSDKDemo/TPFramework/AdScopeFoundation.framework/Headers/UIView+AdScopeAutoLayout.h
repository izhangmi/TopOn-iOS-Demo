//
//  UIView+AdScopeAutoLayout.h
//  AdScopeFoundation
//
//  Created by Cookie on 2023/2/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *AdScopeLayoutReferenceObject NS_STRING_ENUM;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceTop;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceLeft;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceRight;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceBottom;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceWidth;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceHeight;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceCenterX;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceCenterY;
FOUNDATION_EXPORT AdScopeLayoutReferenceObject const AdScopeLayoutReferenceBaseline;

@class AdScopeAutoLayoutModel;

@interface AdScopeAutoLayoutModel : NSObject

/** 边距，固定试图外部属性  */
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *marginTop;
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *marginLeft;
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *marginRight;
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *marginBottom;

/** 中心点  */
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *centerXIs;
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *centerYIs;

/** 固定值  */
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *widthIs;
@property (nonatomic, assign, readonly) AdScopeAutoLayoutModel *heightIs;

/** 参考试图或参考试图的属性  */
- (AdScopeAutoLayoutModel * (^)(id superObject))equalTo;
/** 百分比 or 数值 */
- (AdScopeAutoLayoutModel * (^)(NSString *value))numValue;

@end

@interface UIView (AdScopeAutoLayout)

/** 开始自动布局  */
- (nonnull AdScopeAutoLayoutModel *)adScope_layout;
/** 清空之前的自动布局设置，重新开始自动布局(重新生成布局约束并使其在父view的布局序列数组中位置保持不变)  */
- (nonnull AdScopeAutoLayoutModel *)adScope_resetLayout;
/** 更新布局  */
- (void)adScope_updateLayout;
/** 清空布局  */
- (void)adScope_clearLayout;
/** 屏幕旋转布局  */
- (void)adScope_rotationChangeLayout;
/** 布局models  */
@property (nonatomic) AdScopeAutoLayoutModel * _Nullable adScopeLayoutModel;
/** 属性字符串  */
@property (nonatomic) BOOL adScopeAttributedContent;
/** 布局models数组，加入当前试图的父试图数组中，用于自适应布局  */
- (NSMutableArray *_Nullable)adScopeAutoLayoutModelsArray;
/** 限制值  */
@property (nonatomic, copy) NSString *adScopeMaxWidthIs;
@property (nonatomic, copy) NSString *adScopeMaxHeightIs;
@property (nonatomic, copy) NSString *adScopeMinWidthIs;
@property (nonatomic, copy) NSString *adScopeMinHeightIs;
@property (nonatomic, assign) BOOL adScopeRotationUpdate;
@property (nonatomic, assign) BOOL adScopeAutoWidth;
@property (nonatomic, assign) BOOL adScopeAutoHeight;
@property (nonatomic, assign) CGFloat adScopeAutoScale;

@end

@interface AdScopeAutoLayoutModelItem : NSObject

/** 布局参考试图  */
@property (nonatomic, weak) UIView * _Nullable refView;
/** 参考方向  */
@property (nonatomic, strong) AdScopeLayoutReferenceObject refValue;
/** 数值  */
@property (nonatomic, assign) NSString *numValue;

@end

@interface UIView (AdScopeAutoLayoutReferenceObject)

@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutTop;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutLeft;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutRight;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutBottom;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutWidth;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutHeight;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutCenterX;
@property (nonatomic, strong, readonly) AdScopeAutoLayoutModelItem *adScopeLayoutCenterY;

@end

@interface UIView (AdScopeViewFrameExtention)

/** 视图左边距 */
@property (nonatomic ,assign) CGFloat adScopeFrameLeft;
/** 视图右边距 */
@property (nonatomic ,assign) CGFloat adScopeFrameRight;
/** 视图顶边距 */
@property (nonatomic, assign) CGFloat adScopeFrameTop;
/** 视图底边距 */
@property (nonatomic, assign) CGFloat adScopeFrameBottom;
/** 视图宽度 */
@property (nonatomic ,assign) CGFloat adScopeFrameWidth;
/** 视图高度 */
@property (nonatomic ,assign) CGFloat adScopeFrameHeight;
/** 视图中心X */
@property (nonatomic ,assign) CGFloat adScopeFrameCenterX;
/** 视图中心Y */
@property (nonatomic ,assign) CGFloat adScopeFrameCenterY;
/** 视图Size */
@property (nonatomic ,assign) CGSize adScopeFrameSize;

@end

NS_ASSUME_NONNULL_END
