# RV32i CPU 单周期以及流水线实现

## 仿真测试

|汇编代码文件|机器码文件|功能描述|预期结果|单周期测试结果|流水线测试结果|
|:---:|:---:|:---:|:---:|:---:|:---:|
|[test_branch.asm](./test/test_branch.asm)|[test_branch.hex](./test/test_branch.hex)|测试跳转指令|[test_branch.png](./docs/test_branch.png)||✅|

## 项目目录

|目录或文件|描述|
|:---:|:---:|
|`docs/`|存放图片|
|`pipelined/`|存放流水线CPU代码|
|`single_cycle/`|存放单周期CPU代码|
|`test/`|存放测试文件|
|`README.md`|项目说明文件|
