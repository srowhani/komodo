<template>
  <section id='dashboard'>
    <div class='content'>
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
          <md-button
            class="md-raised"
            :md-ripple="false"
            @click="_settlePot">Settle
          </md-button>
        </div>
      </div>
    </div>
  </section>
</template>

<script type='text/x-template'>
  import Komodo from '@/js/Komodo'
  import { toDataUrl } from 'ethereum-blockies'

  export default {
    name: 'dashboard',
    data () {
      return {
        _contract: null,
        _currentAccount: null,
        _currentPot: null,
        _currentBetAmount: 1,
        balance: null,
      }
    },
    created () {
      this._currentPot = null
      this._currentBetAmount = 1
      this._contract = null
    },
    async mounted () {
      const web3 = window.web3
      this._contract = await Komodo.init()
      console.log(this._contract)

      this._currentPot = {
        participants: {}
      }

      this._currentPot._id = (await this._contract.fetchCurrentPotId.call()).toString()

      this.$forceUpdate()

      this._joinPotEventLastBlock = 0
      this._joinPotEventPollingCycle = 1500


      this._pollJoinEventInterval = setInterval(() => {
        console.log('woo')
        const _initSettleEvent = this._contract.CallbackFired({}, {
          fromBlock: 0,
          toBlock: 'latest'
        })

        _initSettleEvent.watch((error, result) => {
          console.log(error, result)

          // _initSettleEvent.stopWatching()
        })

        const _joinPotEvent = this._contract.JoinPot({
          _potId: 1
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
            console.log(this._currentPot)
            this.$forceUpdate()
          }
          _joinPotEvent.stopWatching()
        })
      }, this._joinPotEventPollingCycle)

      this.$forceUpdate()

      const accounts = web3.eth.accounts || []
      this._currentAccount = accounts[0]
      web3.eth.getBalance(this._currentAccount, (err, balance) => {
        this.balance = web3.fromWei(balance.toString())
      })
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
      },
      async _settlePot () {
        const account = this._currentAccount
        const contract_address = this._contract.address

        const result = await this._contract._initSettle({
          from: account,
          to: contract_address,
          gas: 250000
        })
        console.log(result)
      }
    }
  }
</script>

<style lang="scss" scoped>
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

</style>
