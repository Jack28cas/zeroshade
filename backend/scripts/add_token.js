// Simple script to add a token manually
const axios = require('axios');

const tokenAddress = process.argv[2] || '0x0001be7154d1142684a8585e44c5efbe6ad98dc6fb70a70ef4c1de5cd03d1738';

axios.post('http://localhost:3001/api/tokens', {
  address: tokenAddress
})
  .then(response => {
    console.log('✅ Token added successfully:', response.data);
  })
  .catch(error => {
    console.error('❌ Error adding token:', error.response?.data || error.message);
  });

