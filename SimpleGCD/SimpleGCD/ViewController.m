//
//  ViewController.m
//  SimpleGCD
//
//  Created by Rob Napier on 8/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, readwrite, weak) IBOutlet UILabel *label;
@property (nonatomic, readwrite, assign) NSUInteger count;
@property (nonatomic, readwrite, strong) dispatch_queue_t queue;
@property (nonatomic, readwrite, assign) BOOL shouldRun;
@end

@implementation ViewController {
  NSUInteger _count;
}

- (void)addNextOperation {
  __weak typeof(self) myself = self;
  double delayInSeconds = 3.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 
                                          delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, self.queue, ^(void){
    myself.count = myself.count + 1;
      [self addNextOperation];
  });
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.queue = dispatch_queue_create("net.robnapier.SimpleGCD.ViewController",
                                     DISPATCH_QUEUE_CONCURRENT);
    
    
 //  self.count = 0;
   // [self addNextOperation];
    
    
   

    
    dispatch_queue_t queue = dispatch_queue_create("sc", DISPATCH_QUEUE_CONCURRENT);
    //异步执行
    dispatch_async(queue, ^{
       // [NSThread sleepForTimeInterval:5];
        NSLog(@"111 --- %@",[NSThread currentThread]);
     });
    
    
    dispatch_async(queue, ^{
        
         NSLog(@"222 --- %@",[NSThread currentThread]);
       
    });
    dispatch_async(queue, ^{
        
       NSLog(@"333 --- %@",[NSThread currentThread]);
       
    });
    
    //延时提交1,队列设置为自定义队列
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), queue, ^{
        NSLog(@"hehehe --- %@",[NSThread currentThread]);
    });

}

- (void)viewDidUnload {
  dispatch_suspend(self.queue);
  self.queue = nil;
  [self setLabel:nil];
  [super viewDidUnload];
}

- (NSUInteger)count {
  __block NSUInteger count;
	dispatch_sync(self.queue, ^{
		count = _count;
	});
    return count;
}

- (void)setCount:(NSUInteger)count {
    /*
     一个dispatch barrier 允许在一个并发队列中创建一个同步点。当在并发队列中遇到一个barrier, 他会延迟执行barrier的block,等待所有在barrier之前提交的blocks执行结束。 这时，barrier block自己开始执行。 之后， 队列继续正常的执行操作。
     
     调用这个函数总是在barrier block被提交之后立即返回，不会等到block被执行。当barrier block到并发队列的最前端，他不会立即执行。相反，队列会等到所有当前正在执行的blocks结束执行。到这时，barrier才开始自己执行。所有在barrier block之后提交的blocks会等到barrier block结束之后才执行。
     
     这里指定的并发队列应该是自己通过dispatch_queue_create函数创建的。如果你传的是一个串行队列或者全局并发队列，这个函数等同于dispatch_async函数。
     
     文／alvin_ding（简书作者）
     原文链接：http://www.jianshu.com/p/d4d6a0338b54
     著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
     */
    
    
  dispatch_barrier_async(self.queue, ^{
    _count = count;
  });

    
    dispatch_async(dispatch_get_main_queue(), ^{
    self.label.text = [NSString stringWithFormat:@"%d", count];
        printf("主线程更新count＝%d\n",count);
  });
}

@end
