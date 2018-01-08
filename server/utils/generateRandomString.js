module.exports =  n => (Math.random()
  .toString(36)+Array(n).join('0'))
  .slice(2, n + 2)
