import argparse

def read_sector(device, sector_number, output_file, sector_size):
    with open(device, 'rb') as f:
        # 定位到目标扇区
        f.seek(sector_number * sector_size)
        # 读取扇区数据
        data = f.read(sector_size)
    with open(output_file, 'wb') as f:
        # 将扇区数据写入输出文件
        f.write(data)

def write_sector(device, sector_number, input_file, sector_size):
    erase_sector(device, sector_number, sector_size)
    with open(input_file, 'rb') as f:
        # 读取输入文件数据
        data = f.read()
    with open(device, 'r+b') as f:
        # 定位到目标扇区
        f.seek(sector_number * sector_size)
        # 写入数据到扇区
        f.write(data)

def erase_sector(device, sector_number, sector_size):
    with open(device, 'r+b') as f:
        # 定位到目标扇区
        f.seek(sector_number * sector_size)
        # 将扇区数据全置为零
        f.write(b'\x00' * sector_size)

def main():
    parser = argparse.ArgumentParser(description='Sector Read/Write Tool')
    parser.add_argument('--device', help='path to the target device')
    parser.add_argument('--sn', type=int, help='target sector number', default=1)
    parser.add_argument('--operation', choices=['read', 'write'], help='operation to perform, default is read', default="read")
    parser.add_argument('--file', help='input/output file path')
    parser.add_argument('--ss', type=int, help='size of sector', default=512 ,required=False)
    args = parser.parse_args()

    device = args.device
    sector_number = args.sn
    operation = args.operation
    file_path = args.file

    sector_size = args.ss  # 扇区大小，根据实际情况调整

    if operation == 'read':
        read_sector(device, sector_number, file_path, sector_size)
        print(f'Sector {sector_number} read and saved to {file_path}')
    elif operation == 'write':
        write_sector(device, sector_number, file_path, sector_size)
        print(f'File {file_path} written to sector {sector_number} on {device}')

if __name__ == '__main__':
    main()
