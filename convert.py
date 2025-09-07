import subprocess
import os
from sys import argv
from typing import Union


def bin2mem(input_file: str, output_file: str) -> None:
    """
    将 .bin 文件抓换为 .hex 文件

    :param input_file: 输入的 .bin 文件路径
    :param output_file: 输出的 .hex 文件路径
    :return: None
    """
    with open(input_file, 'rb') as f:
        bin_data = f.read()
    
    with open(output_file, 'w') as f:
        index = 0
        b0 = 0
        b1 = 0
        b2 = 0
        b3 = 0
        for byte in bin_data:
            if index == 0:
                b0 = byte
                index += 1
            elif index == 1:
                b1 = byte
                index += 1
            elif index == 2:
                b2 = byte
                index += 1
            elif index == 3:
                b3 = byte
                index = 0
                f.write(bytearray([b3, b2, b1, b0]).hex() + '\n')


def asm2mem(input_file: str, output_file: Union[str, None] = None, temp_file_prefix: Union[str, None] = None, cleanup: bool = True, verbose: bool = True) -> None:
    """
    将 .asm 文件转换为 .hex 文件

    :param input_file: 输入的 .asm 文件路径
    :param output_file: 输出的 .hex 文件路径
    :param temp_name: 临时文件名前缀
    :param cleanup: 是否删除临时文件，默认为 True
    :param verbose: 是否打印详细信息，默认为 True
    :return: None
    """
    # 检查输入文件是否存在
    if os.path.exists(input_file) is False:
        raise FileNotFoundError(f"输入文件 {input_file} 不存在。")

    if verbose:
        print(f"正在处理 {input_file}...")

    # 设置默认文件名
    if output_file is None:
        output_file = input_file.split('.')[0] + '.hex'
    if temp_file_prefix is None:
        temp_file_prefix = input_file.split('.')[0]

    # 设置命令
    commend_asm2o = ["riscv64-unknown-elf-as", "-march=rv32i", "-mabi=ilp32", "-o", f"{temp_file_prefix}.o", input_file]
    commend_o2elf = ["riscv64-unknown-elf-ld", "-m", "elf32lriscv", "-Ttext", "0x0", "--entry=0x00", f"{temp_file_prefix}.o", "-o", f"{temp_file_prefix}.elf"]
    commend_elf2bin = ["riscv64-unknown-elf-objcopy", "-O", "binary", f"{temp_file_prefix}.elf", f"{temp_file_prefix}.bin"]

    try:
        # 执行命令
        if verbose:
            print("步骤1：汇编...")
        subprocess.run(commend_asm2o, shell=True)
        if verbose:
            print("步骤2：链接...")
        subprocess.run(commend_o2elf, shell=True)
        if verbose:
            print("步骤3：生成二进制文件...")
        subprocess.run(commend_elf2bin, shell=True)
        if verbose:
            print("步骤4：生成 .hex 文件...")
        bin2mem(f"{temp_file_prefix}.bin", output_file)
        if verbose:
            print(f"已生成 {output_file}")
    finally:
        # 删除临时文件
        if cleanup:
            for temp_file in [f"{temp_file_prefix}.o", f"{temp_file_prefix}.elf", f"{temp_file_prefix}.bin"]:
                if os.path.exists(temp_file):
                    os.remove(temp_file)
                    if verbose:
                        print(f"已删除临时文件 {temp_file}")
                        

if __name__ == "__main__":
    if len(argv) == 4:
        input_file = argv[1]
        output_file = argv[2]
        temp_name = argv[3]
        asm2mem(input_file, output_file, temp_name)
    elif len(argv) == 3:
        input_file = argv[1]
        output_file = argv[2]
        print("临时文件名默认为 temp")
        asm2mem(input_file, output_file)
    elif len(argv) == 2:
        input_file = argv[1]
        print(f'输出文件名默认为 {input_file.split(".")[0] + ".hex"}')
        print(f'临时文件名前缀默认为 {input_file.split(".")[0]}')
        asm2mem(input_file)
    else:
        print("正确用法: python test.py <input_file.asm> [output_file.hex] [temp_name]")
