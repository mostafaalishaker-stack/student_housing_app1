const serverless = require('serverless-http');
const { app, syncDb } = require('../../backend/src/index');

let dbReady = false;

exports.handler = async (event, context) => {
  if (!dbReady) {
    try {
      await syncDb();
      dbReady = true;
    } catch (e) {
      console.error('DB sync failed:', e.message);
    }
  }
  const handler = serverless(app);
  return handler(event, context);
};
