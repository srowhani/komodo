<template>
  <div id='app'>
    <md-toolbar class="md-accent" md-elevation="1">
      <h3 class="md-title" style="flex: 1">
        {{title}}
      </h3>
      <md-menu md-direction="bottom-end">
        <md-avatar>
          <img :src='account_logo'></img>
        </md-avatar>
        <md-button md-menu-trigger>{{default_account}}</md-button>
      </md-menu>
    </md-toolbar>
    <router-view></router-view>
  </div>
</template>

<script>
import Vue from 'vue'
import VueMaterial from 'vue-material'
import { toDataUrl } from 'ethereum-blockies'

import 'vue-material/dist/vue-material.min.css'

Vue.use(VueMaterial)

export default {
  name: 'app',
  props: [
    'title',
    'default_account',
    'accounts'
  ],
  computed: {
    account_logo () {
      if (!this.default_account) {
        return
      }
      return toDataUrl(this.default_account)
    }
  }
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
