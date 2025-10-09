<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';

const title = ref('');
const content = ref('');
const msg = ref('');

async function save() {
  try {
    const res = await axios.post('/api/articles', { title: title.value, content: content.value });
    msg.value = res.data?.message || '已保存';
  } catch (e: any) {
    msg.value = e?.response?.data?.message || '保存失败';
  }
}
</script>

<template>
  <div>
    <h2>写文章</h2>
    <input v-model="title" placeholder="标题" />
    <textarea v-model="content" placeholder="内容" rows="10"></textarea>
    <button @click="save">保存</button>
    <p>{{ msg }}</p>
  </div>
</template>


