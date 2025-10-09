<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';

const username = ref('');
const password = ref('');
const msg = ref('');

async function submit() {
  try {
    const res = await axios.post('/api/users/login', { username: username.value, password: password.value });
    msg.value = res.data?.message || '登录成功';
  } catch (e: any) {
    msg.value = e?.response?.data?.message || '登录失败';
  }
}
</script>

<template>
  <div>
    <h2>登录</h2>
    <input v-model="username" placeholder="用户名" />
    <input v-model="password" placeholder="密码" type="password" />
    <button @click="submit">登录</button>
    <p>{{ msg }}</p>
  </div>
</template>


