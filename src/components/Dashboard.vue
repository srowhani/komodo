<template>
  <section id='dashboard'>
    <div class='content'>
      <div class='balance'>
        <h3>Balance</h3>
        {{balance}} ETH
      </div>
      <div class='contract'>
        <h3>KomodoGateway Contract Information</h3>
        {{contract.address}}
      </div>
      <div v-if='_availablePot' class='pot'>
        <h3>Current Pot</h3>

      </div>
    </div>
  </section>
</template>

<script>
  import Komodo from '@/js/Komodo'
  export default {
    name: 'dashboard',
    data () {
      return {
        _currentPot: null,
        contract: null,
        balance: null
      }
    },
    async mounted () {
      const web3 = window.web3
      try {
        this.contract = await Komodo.init()
        console.log(this.contract)
      } catch (e) {
        console.error(e)
      }

      web3.eth.getBalance(web3.eth.defaultAccount, (err, result) => {
        if (err) {
          throw err
        }
        this.balance = web3.fromWei(result.toString())
      })
    },
    methods: {
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
