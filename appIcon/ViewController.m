//
//  ViewController.m
//  appIcon
//
//  Created by 王振坤 on 2017/3/13.
//  Copyright © 2017年 伟东云教育. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *filePathLabel;

@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet NSImageView *muImageView;

@property (weak) IBOutlet NSTextField *iconSizeArrayM;

@property (weak) IBOutlet NSTextField *finishPathLabel;

@property (weak) IBOutlet NSTextField *mulconPathLabel;

@property (weak) IBOutlet NSTextField *muFinishPathLabel;

@property (weak) IBOutlet NSTextField *file3PathLabel;

@property (weak) IBOutlet NSTextField *finish3PathLabel;

@property (weak) IBOutlet NSButton *imageView3;

@property (weak) IBOutlet NSTextField *x;
@property (weak) IBOutlet NSTextField *y;
@property (weak) IBOutlet NSTextField *w;
@property (weak) IBOutlet NSTextField *h;

@end

@implementation NSImage (extension)

- (NSImage*)scaleToSize:(CGSize)size {
    CGFloat width = [self size].width;
    CGFloat height = [self size].height;
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    } else {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    NSImage* scaledImage = [[NSImage alloc] initWithSize:size];
    [scaledImage lockFocus];
    [self drawInRect:CGRectMake(xPos, yPos, width, height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1];
    [scaledImage unlockFocus];
    return scaledImage;
}

- (CGImageRef)imageToCGImageRef; {
    NSData * imageData = [self TIFFRepresentation];
    CGImageRef imageRef;
    if(imageData) {
        CGImageSourceRef imageSource =
        CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    }
    return imageRef;
}

- (NSImage*)imageFromCGImageRef:(CGImageRef)image {
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil;
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    // Create a new image to receive the
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
    return newImage;
}

- (NSImage *)getSubImage:(NSRect)rect {
    CGImageRef newImageRef = CGImageCreateWithImageInRect([self imageToCGImageRef], rect);
    NSImage *newImage = [self imageFromCGImageRef:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iconSizeArrayM.stringValue = @"20, 29, 40, 60, 76, 83.5";
    self.title = @"简单栽剪";
}

- (IBAction)selectIconAction:(NSButtonCell *)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"选择图标地扯"];
    [panel setPrompt:@"确定"];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:YES];
    NSString *path_all;
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        path_all = [[panel URL] path];
        if (sender.tag == 1) {
            self.filePathLabel.stringValue = path_all;
            self.imageView.image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path_all]];
        } else if (sender.tag == 2) {
            self.mulconPathLabel.stringValue = path_all;
            self.muImageView.image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path_all]];
        } else if (sender.tag == 3) {
            self.file3PathLabel.stringValue = path_all;
            self.imageView3.image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path_all]];
            self.x.stringValue = @"0";
            self.y.stringValue = @"0";
            
            self.w.stringValue = [NSString stringWithFormat:@"%.2ld", self.imageView3.image.representations.firstObject.pixelsWide];
            self.h.stringValue = [NSString stringWithFormat:@"%.2ld", self.imageView3.image.representations.firstObject.pixelsHigh];
        }
    }
}

- (void)creatAppIconWith:(NSString *)imgName {
    NSArray *array = [self.iconSizeArrayM.stringValue componentsSeparatedByString:@","];
    NSString *desktopStr = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, true).firstObject;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *iconPath = [NSString stringWithFormat:@"%@/icon", desktopStr];
    if (![fm fileExistsAtPath:iconPath]) {
        [fm createDirectoryAtPath:iconPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSString *fileExtension = [self.filePathLabel.stringValue pathExtension];
    
    for (int i = 0; i<array.count; i++) {
        NSImage *image1 = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imgName]];
        CGFloat w1 = [array[i] floatValue];
        NSImage *img1 = [image1 scaleToSize:CGSizeMake(w1, w1)];
        NSData *data1 = [img1 TIFFRepresentation];
        [data1 writeToFile:[NSString stringWithFormat:@"%@/Icon-%@.%@", iconPath, array[i], fileExtension] atomically:true];
        
        NSImage *image2 = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imgName]];
        CGFloat w2 = [array[i] floatValue] * 2;
        NSImage *img2 = [image2 scaleToSize:CGSizeMake(w2, w2)];
        NSData *data2 = [img2 TIFFRepresentation];
        [data2 writeToFile:[NSString stringWithFormat:@"%@/Icon-%@@2x.%@", iconPath, array[i], fileExtension] atomically:true];
        
        NSImage *image3 = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imgName]];
        CGFloat w3 = [array[i] floatValue] * 3;
        NSImage *img3 = [image3 scaleToSize:CGSizeMake(w3, w3)];
        NSData *data3 = [img3 TIFFRepresentation];
        [data3 writeToFile:[NSString stringWithFormat:@"%@/Icon-%@@3x.%@", iconPath,array[i], fileExtension] atomically:true];
    }
    self.finishPathLabel.stringValue = iconPath;
}

- (void)creatIconWith:(NSString *)imgName rect:(NSRect)rect iconName:(NSString *)iconName tag:(NSInteger)tag {
    NSImage *img1 = [[NSImage alloc] initWithContentsOfFile:imgName];
    NSImage *rimg1 = [img1 getSubImage:rect];
    NSData *data1 = [rimg1 TIFFRepresentation];
    NSString *desktopStr = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, true).firstObject;
    NSString *fileExtension;
    if (tag == 2) {
        fileExtension = [self.mulconPathLabel.stringValue pathExtension];
        self.muFinishPathLabel.stringValue = desktopStr;
    } else if (tag == 3) {
        fileExtension = [self.file3PathLabel.stringValue pathExtension];
        self.finish3PathLabel.stringValue = desktopStr;
    }
    
    [data1 writeToFile:[NSString stringWithFormat:@"%@/%@@3x.%@", desktopStr, iconName, fileExtension] atomically:true];
    CGFloat w = rimg1.size.width/3;
    CGFloat h = rimg1.size.height/3;
    
    NSImage *rimg2 = [rimg1 scaleToSize:CGSizeMake(w*2, h*2)];
    NSData *data2 = [rimg2 TIFFRepresentation];
    [data2 writeToFile:[NSString stringWithFormat:@"%@/%@@2x.%@", desktopStr, iconName, fileExtension] atomically:true];
    
    NSImage *rimg3 = [rimg1 scaleToSize:CGSizeMake(w, h)];
    NSData *data3 = [rimg3 TIFFRepresentation];
    [data3 writeToFile:[NSString stringWithFormat:@"%@/%@.%@", desktopStr, iconName, fileExtension] atomically:true];
}

///  创建方法
- (IBAction)createAction:(NSButton *)sender {
    if (sender.tag == 1) {
        [self creatAppIconWith:self.filePathLabel.stringValue];
    } else if (sender.tag == 2) {
        NSString *iconName = [[self.mulconPathLabel.stringValue lastPathComponent] componentsSeparatedByString:@"."].firstObject;
        NSBitmapImageRep *rep = (NSBitmapImageRep *)[self.muImageView.image representations].firstObject;
        [self creatIconWith:self.mulconPathLabel.stringValue rect:CGRectMake(0, 0, rep.pixelsWide, rep.pixelsHigh) iconName:iconName tag:sender.tag];
    } else if (sender.tag == 3) {
        NSString *iconName = [[self.file3PathLabel.stringValue lastPathComponent] componentsSeparatedByString:@"."].firstObject;
        NSRect rect = NSMakeRect(self.x.floatValue, self.y.floatValue, self.w.floatValue, self.h.floatValue);
        [self creatIconWith:self.file3PathLabel.stringValue rect:rect iconName:iconName tag:sender.tag];
    }
}

@end
