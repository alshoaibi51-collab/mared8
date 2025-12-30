// API Endpoints للمراسلة
const MessageAPI = {
  // GET /api/conversations
  getConversations: async (page = 1, limit = 20) => {
    // Returns user's conversations
  },
  
  // GET /api/conversations/:conversationId/messages
  getMessages: async (conversationId, page = 1, limit = 50) => {
    // Returns messages in a conversation
  },
  
  // POST /api/messages
  sendMessage: async (receiverId, message, messageType = 'text') => {
    // Validates daily limit
    // Checks if users can message each other
    // Saves message to database
    // Sends real-time notification
  },
  
  // WebSocket Events للمراسلة الفورية
  websocketEvents: {
    MESSAGE_SENT: 'message:sent',
    MESSAGE_DELIVERED: 'message:delivered',
    MESSAGE_READ: 'message:read',
    USER_TYPING: 'user:typing',
    USER_ONLINE: 'user:online'
  }
};

// API Middleware للتحقق من الصلاحيات
const MessageMiddleware = {
  checkDailyLimit: async (req, res, next) => {
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];
    
    const dailyCount = await DailyMessageCount.findOne({
      where: { userId, date: today }
    });
    
    const userMembership = await UserMembership.getCurrent(userId);
    const maxMessages = userMembership?.plan?.max_daily_messages || 10;
    
    if (dailyCount >= maxMessages) {
      return res.status(429).json({
        error: 'Daily message limit reached',
        upgradeRequired: true
      });
    }
    
    next();
  },
  
  checkCanMessage: async (req, res, next) => {
    const senderId = req.user.id;
    const receiverId = req.body.receiverId;
    
    // تحقق من الحظر
    const isBlocked = await BlockedUser.exists({
      blockerId: receiverId,
      blockedId: senderId
    });
    
    if (isBlocked) {
      return res.status(403).json({
        error: 'Cannot send message to this user'
      });
    }
    
    // تحقق من شروط المراسلة حسب العضوية
    const senderMembership = await UserMembership.getCurrent(senderId);
    
    if (!senderMembership.can_initiate_chat && !existingConversation) {
      return res.status(403).json({
        error: 'Upgrade required to initiate chat'
      });
    }
    
    next();
  }
};