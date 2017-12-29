// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import Web3 from 'web3'
import router from './router'

Vue.config.productionTip = false

window.addEventListener('load', () => {
  if (typeof web3 !== 'undefined') {
    console.log('Web3 injected browser: OK.')
    window.web3 = new Web3(window.web3.currentProvider)
  } else {
    console.log('Web3 injected browser: Fail. You should consider trying MetaMask.')
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
  }

  /* eslint-disable no-new */
  new Vue({
    el: '#app',
    data: {
      title: 'Komodo',
      accounts: [],
      account: ''
    },
    async mounted () {
      this.accounts = await window.web3.eth.getAccounts()
      this.account = this.accounts[0]
    },
    router,
    template: `
      <App
        v-bind:title="title"
        v-bind:default_account="account"
        v-bind:accounts="accounts"
      >

      </App>
    `,
    components: {
      App
    }
  })
}, false)
