const express = require('express');
const cors = require('cors');
const sgMail = require('@sendgrid/mail');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' })); // Increased limit for base64 images
app.use(express.urlencoded({ extended: true }));

// Email configuration
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

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
    const msg = {
      to: 'splitsy.contact@gmail.com',
      from: 'splitsy.contact@gmail.com', // Must be verified in SendGrid
      subject: `Splitsy Feedback: ${feedbackType}`,
      text: emailBody,
      attachments: []
    };

    // Handle image attachments
    if (attachedImages && attachedImages.length > 0) {
      attachedImages.forEach((imageBase64, index) => {
        msg.attachments.push({
          content: imageBase64,
          filename: `screenshot_${index + 1}.jpg`,
          type: 'image/jpeg',
          disposition: 'attachment'
        });
      });
    }

    // Send email
    console.log('📧 Attempting to send email via SendGrid...');
    const result = await sgMail.send(msg);
    console.log('✅ Feedback email sent successfully:', result[0].statusCode);
    
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
  console.log(`📧 Email configured via SendGrid`);
});

module.exports = app;
