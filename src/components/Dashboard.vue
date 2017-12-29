<template>
  <section id='dashboard'>
  </section>
</template>

<script>
  import Komodo from '@/js/Komodo'
  export default {
    name: 'dashboard',
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
      await Komodo.init()
      console.log(Komodo)
      this._latestBlock = 0
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
