<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';

const username = ref('');
const password = ref('');
const msg = ref('');

async function submit() {
  try {
    const res = await axios.post('/api/users/register', { username: username.value, password: password.value });
    msg.value = res.data?.message || '注册成功';
  } catch (e: any) {
    msg.value = e?.response?.data?.message || '注册失败';
  }
}
</script>

<template>
  <div>
    <h2>注册</h2>
    <input v-model="username" placeholder="用户名" />
    <input v-model="password" placeholder="密码" type="password" />
    <button @click="submit">注册</button>
    <p>{{ msg }}</p>
  </div>
</template>


