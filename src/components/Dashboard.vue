<template>
  <section id='dashboard'>
    <div v-if="!_missingContract" class='content'>
      <div v-if="_currentPot" class='pot'>
        <div class='participants'>
          <h3>Participants</h3>

          <div class='participant' v-for="(participant, address) in _currentPot.participants">
            <img class='md-avatar' :src='participant.profile_img'/>
            <div class='title'>
              <div class='primary'>
                {{address}}
              </div>
              <div class='secondary'>
                {{participant.amount}} ETH
              </div>
            </div>
          </div>
        </div>
        <div class='form'>
          <div class='balance'>
            <h3>Balance</h3>
            {{balance}} ETH
          </div>
          <div v-if="_contract" class='contract'>
            <h3>KomodoGateway Contract Information</h3>
            {{_contract.address}}
          </div>
          <h3>Current Pot</h3>
          {{_currentPot._id}}
          <md-field>
            <label>Amount</label>
            <md-input v-model="_currentBetAmount" type="number"></md-input>
            {{_currentBetAmount}}
          </md-field>

          <md-button
            class="md-raised"
            :md-ripple="false"
            @click="_joinCurrentPot">Join
          </md-button>
        </div>
      </div>
    </div>
    <div v-else>
      KomodoGateway contract has not been loaded
    </div>
    <md-dialog-alert
      :md-active.sync="_potErrorOccured"
      md-content="An error occured trying to transfer funds into your holdings"
      md-confirm-text="Alright" />
  </section>
</template>

<script type='text/x-template'>
  import Komodo from '@/js/Komodo'
  import Poller from '@/js/Poller'

  import { toDataUrl } from 'ethereum-blockies'

  export default {
    name: 'dashboard',
    data () {
      return {
        _contract: null,
        _currentAccount: null,
        _currentPot: null,
        _currentBetAmount: 1,
        _potError: null,
        balance: null,
      }
    },
    created () {
      this.poller = Poller.init();
      this._currentPot = null
      this._currentBetAmount = 1
      this._contract = null
      this._missingContract = false
      this._joinPotEventLastBlock = 0
      this._potErrorEventLastBlock = 0
      this._potError = null
      this._potErrorOccured = null
    },
    async mounted () {
      const web3 = window.web3
      try {
        this._contract = await Komodo.init({
          delay: 5000
        })
      } catch (e) {
        this._missingContract = true
        this.$forceUpdate()
        return
      }

      console.log(this._contract)

      this._currentPot = {
        participants: {}
      }
      this.$forceUpdate()

      this.poller.queue('current_pot', async () => {
        this._currentPot._id = (await this._contract.fetchCurrentPotId.call()).toString()
      })
      this.poller.queue('join_event', () => {
        const _joinPotEvent = this._contract.JoinPot({
          _potId: this._currentPot._id
        }, {
          fromBlock: 1 + this._joinPotEventLastBlock,
          toBlock: 'latest'
        })

        _joinPotEvent.watch((error, result) => {
          if (!error) {
            this._joinPotEventLastBlock = result.blockNumber

            let {
              _address,
              _amount
            } = result.args

            _amount = Number(web3.fromWei(_amount.toString()))

            if (!this._currentPot.participants[_address]) {
              this._currentPot.participants[_address] = {
                profile_img: toDataUrl(_address),
                amount: _amount
              }
            } else {
              this._currentPot.participants[_address].amount += _amount
            }
          }
          _joinPotEvent.stopWatching()
        })
      })
      this.poller.queue('update', () => this.$forceUpdate())
      this.poller.queue('update_balance', () => {
        const accounts = web3.eth.accounts || []
        this._currentAccount = accounts[0]
        web3.eth.getBalance(this._currentAccount, (err, balance) => {
          this.balance = web3.fromWei(balance.toString())
        })
      })
      this.poller.queue('pot_error', () => {
        const _sentMoneyEvent = this._contract.PotError({}, {
          fromBlock: 1 + this._potErrorEventLastBlock,
          toBlock: 'latest'
        })
        _sentMoneyEvent.watch((error, result) => {
          if (!error) {
            this._potErrorEventLastBlock = result.blockNumber
            this._potErrorOccured = true
            this._potError = {
              msg: `
                Unable to transfer funds from mutual holding into your funds
              `
            }
          }

          _sentMoneyEvent.stopWatching()
        })
      })
    },
    destroyed () {
      this.poller.destroy()
    },
    methods: {
      async _joinCurrentPot () {
        const bet = web3.toWei(`${this._currentBetAmount}`)
        const account = this._currentAccount
        const contract_address = this._contract.address
        console.log(this._currentPot._id)

        const result = await this._contract.joinPot({
          from: account,
          to: contract_address,
          gas: 250000,
          value: bet
        })
        console.log(result)
      }
    }
  }
</script>

<style lang="scss">
  .md-dialog-container {
    background: white;
  }
  #dashboard {
    .pot {
      display: flex;
      flex-direction: row;
      flex: 1;
      .participants {
        display: flex;
        flex-direction: column;
        flex: 2;
        .participant {
          height: 45px;
          padding: 2px;
          display: flex;
          flex-direction: row;
          .title {
            display: flex;
            flex-direction: column;
            .primary {
              font-weight: 500;
              text-overflow: ellipsis;
              padding-left: 10px;
            }
            .secondary {
              font-size: 12px;
              padding-left: 10px;
              text-align: left;
            }
          }
        }
      }
      .form {
        display: flex;
        flex-direction: column;
        flex: 3;
        padding: 10px;
      }
    }
  }
</style>
