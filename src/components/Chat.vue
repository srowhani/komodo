<template>
  <section id='chat'>
    <div class='content'>
      <div class='users'>

      </div>
      <div class='messages'>
        <md-list class="md-triple-line">
          <md-list-item v-for='message in messages'>
            <md-avatar>
              <img src="https://placeimg.com/40/40/people/1" alt="People">
            </md-avatar>

            <div class="md-list-item-text">
              <span>{{message._addr}}</span>
              <span>{{message._text}}</span>
            </div>

            <md-button class="md-icon-button md-list-action">
              <md-icon class="md-primary">star</md-icon>
            </md-button>
          </md-list-item>

          <md-divider class="md-inset"></md-divider>
        </md-list>
      </div>

    </div>
    <div class="bottom-bar">
      <div class='item-7'>
        <md-field>
          <label>Message</label>
          <md-textarea v-model="_msg" md-counter="80"></md-textarea>
        </md-field>
      </div>
      <div class='item-2'>
        <md-button class="md-raised md-primary" @click='signup'>Send!</md-button>
      </div>
    </div>
  </section>
</template>

<script>
  import Chat from '@/js/chat'
  export default {
    name: 'signup',
    data () {
      return {
        form: {
          pseudo: undefined
        },
        chat: null,
        messages: [],
        _msg: ''
      }
    },
    async mounted () {
      await Chat.init()
      console.log(Chat)
      this._latestBlock = 0
      this._watchCallback = (err, result) => {
        if (err) {
          clearInterval(this._pollInterval)
          throw err
        }
        if (result.blockNumber > this._latestBlock) {
          this._latestBlock = result.blockNumber
        }
        console.log(this._latestBlock, result)
      }

      this._pollInterval = setInterval(() => {
        Chat.instance.UserRegistered({}, {fromBlock: this._latestBlock + 1, toBlock: 'latest'}).watch(this._watchCallback)
      }, 1000)
      this.form.pseudo = (await window.web3.eth.getAccounts())[0]
    },
    methods: {
      signup () {
        let self = this
        if (typeof this.form.pseudo !== 'undefined' && this.form.pseudo !== '') {
          Chat.instance.register({from: this.form.pseudo}).then(result => {
            console.log(result)
            self.$router.push('/')
          }).catch(err => {
            debugger
            console.log(err)
          })
        }
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
