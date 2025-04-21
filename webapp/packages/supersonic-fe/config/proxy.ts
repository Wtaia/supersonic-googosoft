export default {
  dev: {
    '/api/': {
      target: 'http://127.0.0.1:9080',
      // target: 'http://122.9.35.92:9080',
      changeOrigin: true,
    },
  },
};
