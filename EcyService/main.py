#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
import uuid
import random
import string
import logging
import os
from typing import Optional, Dict, Any

app = Flask(__name__)

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 配置IP和端口（可通过环境变量设置，默认0.0.0.0:5000）
HOST = os.getenv('HOST', '0.0.0.0')
PORT = int(os.getenv('PORT', 8081))

# 用户信息存储（token -> 用户信息）
users_map: Dict[str, Dict[str, Optional[str]]] = {}
# phone -> token 映射
phone_token_map: Dict[str, str] = {}

# 统一响应模型构造函数
def response_model(message: str, code: int, data: Optional[Any] = None) -> Any:
    return jsonify({
        "message": message,
        "code": code,
        "data": data if data is not None else {}
    })

# 生成随机token字符串
def generate_token() -> str:
    """生成随机字符串token"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=32))

# 随机生成用户信息
def generate_user_info(phone: str) -> Dict[str, Optional[str]]:
    # 随机生成姓名
    first_names = ['张', '李', '王', '刘', '陈', '杨', '赵', '黄', '周', '吴']
    last_names = ['伟', '芳', '娜', '秀英', '敏', '静', '丽', '强', '磊', '军']
    name = random.choice(first_names) + random.choice(last_names)
    
    # 随机生成头像URL
    avatar = f"https://img95.699pic.com/photo/40250/6425.jpg_wh300.jpg"
    
    # 生成用户ID
    user_id = str(uuid.uuid4())
    
    return {
        "id": user_id,
        "phone": phone,
        "name": name,
        "avatar": avatar
    }

# 登录接口
@app.route('/login', methods=['POST'])
def login() -> Any:
    # 从请求体的JSON中获取phone
    try:
        data = request.get_json()
        if not data:
            return response_model("请求体不能为空", 400)
        
        phone: Optional[str] = data.get('phone')
        
        if not phone:
            return response_model("phone参数不能为空", 400)
    except Exception as e:
        logging.error(f"解析请求体失败：{e}")
        return response_model("请求体格式错误", 400)
    
    # 检查phone是否已存在
    if phone in phone_token_map:
        # 如果phone已存在，返回已有的token
        token = phone_token_map[phone]
        logging.info(f"用户已存在，phone：{phone}，token：{token}")
    else:
        # 如果phone不存在，生成新用户信息和token
        token = generate_token()
        user_info = generate_user_info(phone)
        users_map[token] = user_info
        phone_token_map[phone] = token
        logging.info(f"新用户登录成功，phone：{phone}，用户信息：{user_info}")
    
    return response_model("登录成功", 200, token)

# 获取用户信息接口
@app.route('/getUserInfo', methods=['POST'])
def get_user_info() -> Any:
    # 从请求头获取 token
    token: Optional[str] = request.headers.get('Authorization')
    
    if not token or token not in users_map:
        return response_model("未登录或 token 无效", 401)
    
    # 从map中获取用户信息
    user_info = users_map[token]
    
    return response_model("获取用户信息成功", 200, user_info)

# 退出登录接口
@app.route('/logout', methods=['POST'])
def logout() -> Any:
    token: Optional[str] = request.headers.get('Authorization')
    
    if token and token in users_map:
        user_info = users_map[token]
        phone = user_info.get('phone')
        # 删除token和phone的映射
        del users_map[token]
        if phone and phone in phone_token_map:
            del phone_token_map[phone]
        logging.info(f"退出登录成功，token：{token}，phone：{phone}")
    
    return response_model("退出登录成功", 200, None)

if __name__ == '__main__':
    print(f"服务器启动于 http://{HOST}:{PORT}")
    app.run(host=HOST, port=PORT, debug=True)