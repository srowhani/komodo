<template>
  <div id='error'>
    <md-toolbar class="md-accent" md-elevation="1">
      <h3 class="md-title" style="flex: 1">
        {{title}}
      </h3>
    </md-toolbar>
    Must be logged in with MetaMask
  </div>
</template>

<script>
import 'vue-material/dist/vue-material.min.css'
import Vue from 'vue'
import VueMaterial from 'vue-material'
Vue.use(VueMaterial)
export default {
  name: 'error',
  props: [
    'title'
  ]
}

</script>

<style lang='scss'>
html, body, .app-container, #app {
  height: 100%;
  min-height: 100%;
  max-height: 100%;
  overflow: hidden;
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  .md-title {
    text-align: left;
  }
}
</style>
