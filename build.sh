#!/bin/bash

# 输出传递的 BuildType 参数
echo "Received BuildType: $BuildType"

# 确保 build.sh 脚本是可执行的
chmod +x ./build.sh

# 执行 build.sh 脚本，传递 BuildType 参数
./build.sh $BuildType

