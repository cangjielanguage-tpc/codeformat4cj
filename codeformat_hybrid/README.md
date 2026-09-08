<div align="center">
<h1>codeformat</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v2.0.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.1.3-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>


## 介绍

codeformat是一个对代码进行格式化的库,目前支持C和C++,OC/OC++,js/ts，Java,Python,Html,Go,kotlin,swift,Rust,C#,Dart,PHP,Cangjie,SQL,Scala,Bash 20种语言


### 特性

本项目为自研项目

- 🚀 支持C和C++代码格式化
- 🚀 支持OC/OC++，js/ts，java，python代码的格式化
- 🚀 支持Html,Go,kotlin,swift,Rust,C#,Dart,PHP,Cangjie,SQL,Scala,Bash代码的格式化
- 🚀 支持仓颉arkts互操作

### 源码目录

```shell
─codeformat_hybrid
  └─src
      └─main
          ├─cangjie
          ├─ets
          └─resources
```

- `codeformat_hybrid` 工程模块 - 编译生成一个har包
- `codeformat_hybrid src` 模块代码目录
- `codeformat_hybrid src main` 模块项目目录
- `codeformat_hybrid src main cangjie` 仓颉代码目录
- `codeformat_hybrid src main ets` ets代码目录
- `codeformat_hybrid src main resources` 资源文件目录



### 接口说明

主要类和函数接口说明详见 [API](https://gitcode.com/Cangjie-TPC/codeformat4cj/blob/codeformat_hybrid_cangjie-plugin-6.1.1_compatibility/doc/feature_api.md)



## 使用说明

### 三方库导入使用

```ets
    1. 通过中心仓下载安装

        ohpm install @cangjie-tpc/codeformat_hybrid
  
        在项目中使用codeformat项目

        import { CodeFormatTS } from '@cangjie-tpc/codeformat_hybrid';
      
    2. 本地编译安装
       
        描述具体的编译过程：

        1.先通过命令把代码下载下来
        git clone -b codeformat_hybrid_cangjie-plugin-5.1.1 https://gitcode.com/Cangjie-TPC/codeformat4cj.git
              
        2.在deveco里选择codeformat_hybrid模块,点击Build菜单,然后点击 Make Module 'codeformat_hybrid' 等待编译完成,项目则编译成功
    
        3. 然后在codeformat_hybrid模块下的build/default/outputs/default/下找到codeformat_hybrid.har
        
        4. 用户在自己应用的module下新建一个文件夹名为har,然后把codeformat_hybrid.har文件放入其中

        5. 然后在用户module下的oh-package.json5下面添加依赖
           "dependencies": {
                "@cangjie-tpc/codeformat_hybrid": "file:./har/codeformat_hybrid.har"
           }
           添加完后点击自动弹出的sync now同步
    
        6. 在项目中使用codeformat项目

        import { CodeFormatTS } from '@cangjie-tpc/codeformat_hybrid';
    
```







### 功能示例

功能示例描述: 将一段C++代码格式化

示例代码如下：
```ets

import { CodeFormatTS } from '@cangjie-tpc/codeformat_hybrid'

@Entry
@Component
struct page1Test {
  
  @State text:string = ""

  code1:string = `
  #include <stdio.h>
  #include <stdlib.h>
  int main() {
  int a = 10;
  int b = 20;
  int sum = a + b;
  printf("Sum: %d\\n", sum);
  return 0;
}
`
  async aboutToAppear(): Promise<void> {
    this.text = new CodeFormatTS().codeFormatDefault("c",this.code1)
  }

  aboutToDisappear(): void {

  }

  build() {
    Row() {
      Scroll() {
        Column() {
          Text(this.text)
        }
        .width('100%')
      }.scrollBar(BarState.Off)
      .height('100%')
    }
  }
}

```

## 约束与限制


| 编号 | 依赖构建工具                                 | 版本号    |
| ---- | -------------------------------------------- | --------- |
| 1    | **DevEco Studio 6.1.1 Release**              | 6.1.1.280 |
| 2    | **cjc**                                      | v1.1.3    |
| 3    | **DevEco Studio-Cangjie Plugin 6.1.1 Beta1** | 6.1.1.280 |
| 4    | **compatibility-sdk-6.1.1.280**              | 6.1.1.280 |

codeformat_hybrid依赖三方库：

| 编号 | 依赖三方库         | 版本号    |
|----|---------------|--------|
| 1  | codeformat    | v1.0.7 | 	 


## 开源协议

本项目基于 [Apache License 2.0](https://gitcode.com/Cangjie-TPC/codeformat4cj/blob/codeformat_hybrid_cangjie-plugin-6.1.1_compatibility/LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。