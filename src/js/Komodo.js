import contract from 'truffle-contract'
import KomodoContract from '@contracts/KomodoGateway.json'

export default {
  contract: null,
  instance: null,
  init () {
    this.contract = contract(KomodoContract)
    this.contract.setProvider(window.web3.givenProvider)
    return this.contract.deployed()
  }
}
