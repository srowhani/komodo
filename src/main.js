// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import Error from './Error'
// import Web3 from 'web3'
import router from './router'

window.addEventListener('load', () => {
  /* eslint-disable no-new */
  new Vue({
    el: '#app',
    data: {
      title: 'Komodo',
      accounts: [],
      _web3Injected: false,
      _shouldRender: false
    },
    async created () {
      this._availableAccounts = false
      this._web3Injected = !!window.web3
      this._shouldRender = false
      if (this._web3Injected) {
        this.accounts = window.web3.eth.accounts || []

        this._shouldRender = !!this.accounts.length

        if (this._shouldRender) {
          this.account = this.accounts[0]
          this.$forceUpdate()
        }
      }
    },
    router,
    template: `
      <div class='app-container' v-if="_shouldRender">
        <App
          v-bind:title="title"
          v-bind:accounts="accounts"
          v-bind:default_account="account"
        >
        </App>
      </div>
      <div class='app-container' v-else>
        <Error v-bind:title="title"/>
      </div>
    `,
    components: {
      App,
      Error
    }
  })
}, false)
