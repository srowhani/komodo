<template>
  <section id='dashboard'>
    <div class='content'>
      <div class='balance'>
        <h3>Balance</h3>
        {{balance}} ETH
      </div>
      <div v-if="_contract" class='contract'>
        <h3>KomodoGateway Contract Information</h3>
        {{_contract.address}}
      </div>
      <div v-if="_currentPot" class='pot'>
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
  </section>
</template>

<script type='text/x-template'>
  import Komodo from '@/js/Komodo'
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

      const event = this._contract.JoinPot({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }, function (error, result) {
        if (!error) {
          console.log(result);
        }
      })

      this.$forceUpdate()

      const accounts = web3.eth.accounts || []
      this._currentAccount = accounts[0]
      web3.eth.getBalance(this._currentAccount, (err, balance) => {
        this.balance = web3.fromWei(balance.toString())
      })

      this._currentPot = {}
      this._currentPot._id = (await this._contract.fetchCurrentPotId.call()).toString()

      this.$forceUpdate()

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
      }
    }
  }
</script>

<style lang="scss" scoped>

  #chat {
    display: flex;
    flex-direction: column;
    height: 100%;
    .content {
      display: flex;
      flex-direction: column;
      flex: 5;
    }
    .bottom-bar {
      display: flex;
      flex-direction: row;
      flex: 1;

      .item {
        &-2 {
          flex: 2;
        }
        &-7 {
          flex: 7;
        }
      }
    }
  }

</style>
