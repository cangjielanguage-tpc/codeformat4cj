<div align="center">
<h1>codeformat4hybrid</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.2-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>


## 介绍

codeformat4hybrid是一个对代码进行格式化的库,目前仅支持C和C++,OC/OC++,js/ts，java,python语言


### 特性

本项目为自研项目

- 🚀 支持C和C++代码格式化
- 🚀 支持OC/OC++，js/ts，java，python代码的格式化
- 🚀 支持仓颉arkts互操作

### 源码目录

```shell
─codeformat4hybrid
  └─src
      └─main
          ├─cangjie
          ├─ets
          └─resources
```

- `codeformat4hybrid` 工程模块 - 编译生成一个har包
- `codeformat4hybrid src` 模块代码目录
- `codeformat4hybrid src main` 模块项目目录
- `codeformat4hybrid src main cangjie` 仓颉代码目录
- `codeformat4hybrid src main ets` ets代码目录
- `codeformat4hybrid src main resources` 资源文件目录

```

### 接口说明

主要类和函数接口说明详见 [API](https://gitcode.com/Cangjie-TPC/codeformat4cj/blob/codeformat_hybrid-cangjie-plugin-5.1.1/doc/feature_api.md)



## 使用说明

### 编译构建

描述具体的编译过程：

```shell
    1.先通过命令把代码下载下来
      git clone -b 分支名 --depth 1 https://gitcode.com/Cangjie-TPC/codeformat4cj.git
              
    2.在deveco里选择codeformat4hybrid模块,点击Build菜单,然后点击 Make Module 'codeformat4hybrid' 等待编译完成,项目则编译成功
    
```

### 三方库导入使用

#### 1. 把codeformat4hybrid作为三方库依赖引入

```ets
用户如何在自己项目里引入codeformat4hybrid，具体步骤如下：

1. 通过git命令,把自己需要的codeformat4hybrid分支拉下来
   git clone -b 分支名 --depth 1 https://gitcode.com/Cangjie-TPC/codeformat4cj.git
   
2. 把codeformat4hybrid项目用deveco编译通过，方法如上面的编译构建

3. 然后在codeformat4hybrid模块下的build/default/outputs/default/下找到codeformat4hybrid.har

4. 用户在自己应用的module下新建一个文件夹名为har,然后把codeformat4hybrid.har文件放入其中

5. 然后在用户module下的oh-package.json5下面添加依赖
   "dependencies": {
        "@cangjie-tpc/codeformat4hybrid": "file:./har/codeformat4hybrid.har"
   }
   添加完后点击自动弹出的sync now同步
    
6. 同步完成后就可以在自己的代码文件里引用codeformat4hybrid里的类了
   
```


### 功能示例
 
功能示例描述: 将一段C++代码格式化

示例代码如下：
```ets

import { CodeFormatTS } from '@cangjie-tpc/codeformat4hybrid'

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

DevEco Studio (5.1.1.851)

Cangjie Support Plugin 5.1.1.851

Cangjie Compiler: 1.0.5

## 开源协议

本项目基于 [Apache License 2.0](https://gitcode.com/Cangjie-TPC/codeformat4cj/blob/codeformat_hybrid-cangjie-plugin-5.1.1/LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。