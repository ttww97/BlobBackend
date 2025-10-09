<template>
  <div class="layout">
    <header class="header">
      <h1>Agent 博客</h1>
      <nav>
        <router-link to="/">首页</router-link>
        <router-link to="/login">登录</router-link>
        <router-link to="/register">注册</router-link>
        <router-link to="/editor">写文章</router-link>
      </nav>
    </header>
    <main>
      <router-view />
    </main>
  </div>
  </template>

<style>
  .layout { max-width: 960px; margin: 0 auto; padding: 16px; }
  .header { display: flex; align-items: center; justify-content: space-between; }
  nav a { margin-right: 12px; }
</style>


