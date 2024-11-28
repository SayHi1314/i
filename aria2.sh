#!/bin/bash

# 定义多个tracker的URL
trackers_list=(
    "https://cf.trackerslist.com/best.txt"
    "https://cf.trackerslist.com/all.txt"
    "https://cf.trackerslist.com/nohttp.txt"
    "https://cf.trackerslist.com/http.txt"
)

# 临时文件存储路径
tmp_file="trackers.txt"

# 清空临时文件
> $tmp_file

# 获取所有tracker列表并合并到临时文件中
for url in "${trackers_list[@]}"; do
    curl -s $url >> $tmp_file
done

# 去除空行和注释
sed -i '/^\s*$/d' $tmp_file
sed -i '/^#/d' $tmp_file

# 将 tracker 列表转换为逗号分隔的字符串
trackers=$(awk '{printf $0","}' $tmp_file | sed 's/,$//')

# 设置 RPC 接口和密钥
rpc="http://246800.v6.rocks:6800/jsonrpc"
passwd=""

# 构造 JSON-RPC 请求
json=$(cat <<EOF
{
  "jsonrpc": "2.0",
  "method": "aria2.changeGlobalOption",
  "id": "cron",
  "params": [
    "token:$passwd",
    {
      "bt-tracker": "$trackers"
    }
  ]
}
EOF
)
echo "$json"
# 发送请求给 aria2 的 RPC 接口，并检查响应状态码
if [ -n "$trackers" ]; then
  response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$json" "$rpc")
  http_code=$(echo "$response" | tail -c 4)  # 提取最后的状态码

  if [ "$http_code" -eq 200 ]; then
    echo "请求成功！"
  else
    echo "请求失败，HTTP 状态码: $http_code"
  fi
fi
