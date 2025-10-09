<script setup lang="ts">
import { ref, onMounted } from 'vue';
import axios from 'axios';

type Article = { id: number; title: string; summary?: string };
const articles = ref<Article[]>([]);

onMounted(async () => {
  const res = await axios.get('/api/articles');
  articles.value = res.data?.data ?? [];
});
</script>

<template>
  <div>
    <h2>最新文章</h2>
    <ul>
      <li v-for="a in articles" :key="a.id">{{ a.title }}</li>
    </ul>
  </div>
</template>


