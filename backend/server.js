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
      additionalComments,
      attachedImages,
      userDisplayName,
      userEmail,
      userUsername
    } = req.body;

    // Create email content
    let emailBody = `
Hello Splitsy Team,

You have received new feedback from the Splitsy iOS app:

USER INFORMATION:
================
Display Name: ${userDisplayName}
Email: ${userEmail}
Username: @${userUsername}

FEEDBACK DETAILS:
================
Type: ${feedbackType}
Priority: ${priority}

Description:
${description}

Device Information:
${deviceInfo}
`;

    if (userJourney) emailBody += `\nUser Journey: ${userJourney}`;
    if (frequency) emailBody += `\nFrequency: ${frequency}`;
    if (impact) emailBody += `\nImpact: ${impact}`;
    if (additionalComments) emailBody += `\n\nAdditional Comments:\n${additionalComments}`;

    emailBody += `\n\nBest regards,
Splitsy Feedback System

---
This email was automatically generated from the Splitsy iOS app.
Please do not reply to this email address.`;

    // Create HTML email content
    let htmlBody = `
    <html>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
      <h2 style="color: #2c3e50;">New Feedback from Splitsy iOS App</h2>
      
      <div style="background-color: #e8f4fd; padding: 20px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #3498db;">
        <h3 style="color: #2c3e50; margin-top: 0;">User Information</h3>
        <p><strong>Display Name:</strong> ${userDisplayName}</p>
        <p><strong>Email:</strong> ${userEmail}</p>
        <p><strong>Username:</strong> @${userUsername}</p>
      </div>
      
      <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">
        <h3 style="color: #2c3e50; margin-top: 0;">Feedback Details</h3>
        <p><strong>Type:</strong> ${feedbackType}</p>
        <p><strong>Priority:</strong> ${priority}</p>
        <p><strong>Description:</strong></p>
        <p style="background-color: white; padding: 15px; border-left: 4px solid #3498db;">${description.replace(/\n/g, '<br>')}</p>
        <p><strong>Device Information:</strong> ${deviceInfo}</p>
    `;

    if (userJourney) htmlBody += `<p><strong>User Journey:</strong> ${userJourney}</p>`;
    if (frequency) htmlBody += `<p><strong>Frequency:</strong> ${frequency}</p>`;
    if (impact) htmlBody += `<p><strong>Impact:</strong> ${impact}</p>`;
    if (additionalComments) htmlBody += `<p><strong>Additional Comments:</strong></p><p style="background-color: white; padding: 15px; border-left: 4px solid #e74c3c;">${additionalComments.replace(/\n/g, '<br>')}</p>`;

    htmlBody += `
      </div>
      
      <p style="color: #7f8c8d; font-size: 12px;">
        This email was automatically generated from the Splitsy iOS app.<br>
        Please do not reply to this email address.
      </p>
    </body>
    </html>
    `;

    // Email options
    const msg = {
      to: 'splitsy.contact@gmail.com',
      from: 'Splitsy Team <splitsy.contact@gmail.com>', // More professional format
      subject: `Splitsy Feedback: ${feedbackType}`,
      text: emailBody,
      html: htmlBody,
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
    const result = await sgMail.send(msg);
    
    res.status(200).json({ 
      success: true, 
      message: 'Feedback sent successfully' 
    });

  } catch (error) {
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
  // Server started successfully
});

module.exports = app;
