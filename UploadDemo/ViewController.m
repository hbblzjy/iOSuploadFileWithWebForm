//
//  ViewController.m
//  UploadDemo
//
//  Created by JasonHao on 2017/5/5.
//  Copyright © 2017年 JasonHao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSString *boundary;
    NSString *fileParam;
    NSString *fileName;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    boundary = @"----------aa12345678aa";
    fileParam = @"file";
    fileName = @"image.png";//此文件提前放在 沙盒文件 区域，把自己上传的媒体资源，只要换成data类型就可以，实现类似于发布等一些功能
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn setTitle:@"上传图片" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
-(void)btnClick:(UIButton *)btn{
    [self method4];
}
//请求方法
-(void)method4{
    NSURL *uploadURL = [NSURL URLWithString:@"http://192.168.124.233/report/addReportTest"];
    NSLog(@"请求路径为%@",uploadURL);//接口路径：根据自己的需要修改
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        //body
        NSData *body = [self prepareDataForUpload];
        
        //request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:uploadURL];
        [request setValue:@"BBH" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"max-age=7200" forHTTPHeaderField:@"Cache-Control"];
        
        //设置上传数据的长度及格式
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)body.length]forHTTPHeaderField:@"Content-Length"];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:body];
        
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"message: %@", message);
            
            [session invalidateAndCancel];
        }];
        
        [uploadTask resume];
    });
}
//生成bodyData
-(NSData*) prepareDataForUpload
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *uploadFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    //NSLog(@"documen   %@",uploadFilePath);
    NSString *lastPathfileName = [uploadFilePath lastPathComponent];
    NSMutableData *bodyData = [NSMutableData data];
    NSData *dataOfFile = [[NSData alloc] initWithContentsOfFile:uploadFilePath];
    
    NSDictionary *paramDic = @{@"userId":@"1234",@"content":@"哈哈",@"isPublic":@"0",@"fileType":@"0"};
    
    [paramDic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        
        NSString *boundry1 = [NSString stringWithFormat:@"--%@\r\n",boundary];
        
        [bodyData appendData:[[NSString stringWithFormat:@"%@", boundry1] dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key];
        NSLog(@"%@",disposition);
        [bodyData appendData:[[NSString stringWithFormat:@"%@", disposition] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"%@", obj] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    if (dataOfFile) {
        //连续上传相同的三张图片
        [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;  name=\"%@\"; filename=\"%@\"\r\n", fileParam, lastPathfileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Type: application/zip\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:dataOfFile];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParam, lastPathfileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Type: application/zip\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:dataOfFile];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParam, lastPathfileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Type: application/zip\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:dataOfFile];
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return bodyData;
}

//写在数据请求的公共文件中
//#pragma mark ---- 利用 AFNetworking 上传图片或小视频
//+ (AFHTTPSessionManager *)sharedClient;
//#pragma mark ---- 上传图片或小视频
//+ (AFHTTPSessionManager *)sharedClient {
//    
//    static AFHTTPSessionManager *_sharedClient = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        //        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
//        
//        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
//        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
//                                                          diskCapacity:50 * 1024 * 1024
//                                                              diskPath:nil];
//        
//        [config setURLCache:cache];
//        
//        _sharedClient = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
//        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
//        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
//    });
//    
//    return _sharedClient;
//}


//-------写在上传内容的界面中
//        [SVProgressHUD showWithStatus:@"正在上传"];
//        [self PostData:DISCLOSE_SEND_INFO_URL parameters:paramDic fileData:imageDataArr fileType:@"jpg" mimeType:@"image/jpeg" success:^(id responseObject) {
//
//            [SVProgressHUD showSuccessWithStatus:@"上传成功!"];
//            _sendBtn.userInteractionEnabled = YES;
//        } failure:^(NSError *error) {
//
//            [SVProgressHUD showErrorWithStatus:@"上传失败!"];
//            _sendBtn.userInteractionEnabled = YES;
//        }];
//- (NSURLSessionDataTask *)PostData:(NSString *)URLString
//                        parameters:(id)parameters
//                          fileData:(NSArray *)fileDataArr
//                          fileType:(NSString *)fileType
//                          mimeType:(NSString *)mimeType
//                           success:(void (^)(id responseObject))GetSuccess
//                           failure:(void (^)(NSError *error))Getfailure {
//
//    NSString *url = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURLSessionDataTask *task = [[HttpRequestUtil sharedClient] POST:url parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
//
//       int i = 0;
//       for (NSData *fileData in fileDataArr) {
//
//           [formData appendPartWithFileData:fileData name:[NSString stringWithFormat:@"random%d",i] fileName:[NSString stringWithFormat:@"random%d.%@",i,fileType] mimeType:mimeType];
//           i++;
//       }
//    }success:^(NSURLSessionDataTask *task,id responseObject){
//
//       dispatch_async(dispatch_get_main_queue(), ^{
//           GetSuccess(responseObject);
//       });
//
//    }failure:^(NSURLSessionDataTask *task,NSError *error){
//       Getfailure(error);
//    }];
//    return task;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
