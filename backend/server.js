const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Increased limit for base64 images
app.use(express.urlencoded({ extended: true }));

// Email configuration
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER, // splitsy.contact@gmail.com
    pass: process.env.EMAIL_PASS  // App-specific password
  },
  connectionTimeout: 10000, // 10 seconds
  greetingTimeout: 10000,   // 10 seconds
  socketTimeout: 10000      // 10 seconds
});

// Feedback endpoint
app.post('/api/feedback', async (req, res) => {
  try {
    const {
      feedbackType,
      priority,
      description,
      deviceInfo,
      userJourney,
      frequency,
      impact,
      contactEmail,
      additionalComments,
      attachedImages
    } = req.body;

    // Create email content
    let emailBody = `
Feedback Type: ${feedbackType}
Priority: ${priority}

Description:
${description}

Device Information:
${deviceInfo}
`;

    if (userJourney) emailBody += `\nUser Journey: ${userJourney}`;
    if (frequency) emailBody += `\nFrequency: ${frequency}`;
    if (impact) emailBody += `\nImpact: ${impact}`;
    if (contactEmail) emailBody += `\nContact Email: ${contactEmail}`;
    if (additionalComments) emailBody += `\n\nAdditional Comments:\n${additionalComments}`;

    emailBody += '\n\n---\nSent from Splitsy iOS App';

    // Email options
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: 'splitsy.contact@gmail.com',
      subject: `Splitsy Feedback: ${feedbackType}`,
      text: emailBody,
      attachments: []
    };

    // Handle image attachments
    if (attachedImages && attachedImages.length > 0) {
      attachedImages.forEach((imageBase64, index) => {
        mailOptions.attachments.push({
          filename: `screenshot_${index + 1}.jpg`,
          content: imageBase64,
          encoding: 'base64'
        });
      });
    }

    // Send email
    console.log('📧 Attempting to send email...');
    const result = await transporter.sendMail(mailOptions);
    console.log('✅ Feedback email sent successfully:', result.messageId);
    
    res.status(200).json({ 
      success: true, 
      message: 'Feedback sent successfully' 
    });

  } catch (error) {
    console.error('❌ Error sending feedback email:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to send feedback' 
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'Splitsy Feedback API is running' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Splitsy Feedback API running on port ${PORT}`);
  console.log(`📧 Email configured for: ${process.env.EMAIL_USER}`);
});

module.exports = app;
