import contract from 'truffle-contract'
import ChatContract from '@contracts/Chat.json'

export default {
  contract: null,
  instance: null,
  init () {
    this.contract = contract(ChatContract)
    this.contract.setProvider(window.web3.currentProvider)
    return this.contract.deployed().then(_instance => {
      this.instance = _instance
    })
  }
}
