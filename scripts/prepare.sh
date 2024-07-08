#!/bin/sh

# 更改到home目录，默认安装路径为 /home/pjdfstest。
cd /home

# 克隆pjdfstest项目。这是脚本的目标，获取测试工具的源代码。
git clone git@github.com:Damon-wenc/pjdfstest.git

# 进入pjdfstest目录，接下来的所有操作都在这个项目目录下进行。
cd pjdfstest

# 自动配置项目，为编译做准备。如果失败，终止脚本执行。
autoreconf -ifs || {
    echo "Autoreconf failed."
    exit 1
}

# 运行configure脚本，配置项目。如果失败，终止脚本执行。
./configure || {
    echo "Configure failed."
    exit 2
}

# 编译pjdfstest工具。如果失败，终止脚本执行。
make pjdfstest || {
    echo "Make failed."
    exit 3
}

# 安装pjdfstest工具。如果失败，终止脚本执行。
make install || {
    echo "Install failed."
    exit 4
}

# 打印消息，表示pjdfstest的准备已完成。
echo "Prepare pjdfstest done."

# 脚本执行成功结束。
exit 0