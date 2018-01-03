import contract from 'truffle-contract'
import KomodoContract from '@contracts/KomodoGateway.json'

export default {
  contract: null,
  init () {
    this.contract = contract(KomodoContract)
    this.contract.setProvider(new window.web3.providers.HttpProvider())

    return this.contract.deployed()
  }
}
