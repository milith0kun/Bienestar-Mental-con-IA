const express = require('express');
const { protect } = require('../middleware/auth');
const subscriptionController = require('../controllers/subscription.controller');

const router = express.Router();

// Public routes
router.get('/features', subscriptionController.getPremiumFeatures);
router.post('/webhook', subscriptionController.stripeWebhook);

// Protected routes
router.get('/status', protect, subscriptionController.getSubscriptionStatus);
router.post('/create-checkout', protect, subscriptionController.createCheckoutSession);
router.post('/upgrade-demo', protect, subscriptionController.upgradeToPremiumDemo);
router.post('/cancel', protect, subscriptionController.cancelSubscription);

module.exports = router;
