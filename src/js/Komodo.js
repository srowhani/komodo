import contract from 'truffle-contract'
import KomodoContract from '@contracts/KomodoToken.json'

export default {
  contract: null,
  instance: null,
  init () {
    this.contract = contract(KomodoContract)
    this.contract.setProvider(window.web3.currentProvider)
    return this.contract.deployed().then(_instance => {
      this.instance = _instance
    })
  }
}
