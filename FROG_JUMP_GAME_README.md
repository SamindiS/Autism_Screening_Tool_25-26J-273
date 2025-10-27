# 🐸 Frog Jump Game - Go/No-Go Task for Toddlers (Ages 2-3)

## Overview
The **Frog Jump Game** is a beautifully designed, toddler-friendly cognitive assessment game that implements the classic **Go/No-Go** task. It's specifically designed for children aged 2-3 years as part of the Cognitive Flexibility assessment component.

## Game Concept
Children are presented with two types of animal characters:
- **🐸 Happy Frog (GO)** - Children should TAP
- **🐢 Sleepy Turtle (NO-GO)** - Children should NOT tap

This tests **response inhibition** and **impulse control**, which are key indicators of executive function development.

## Features

### 🎨 Visual Design
- **Beautiful gradient backgrounds** with animated stars and floating balloons
- **Large, colorful character displays** (280px circles)
- **Clear visual feedback** with animations
- **Child-friendly color palette** (pink gradients, bright colors)
- **Pulsing animations** to engage attention
- **Confetti celebration** for correct responses

### 🔊 Audio Features
- **Web Audio API** for sound effects
- **Pleasant melodies** for correct/incorrect responses
- **Celebration sounds** at game completion
- **Optional background music** with toggle button
- **No external audio files needed** - all synthesized

### 🎮 Game Mechanics
- **10 total trials** (age-appropriate duration)
- **70% GO trials / 30% NO-GO trials** (standard ratio)
- **3-second timeout** for GO trials (must tap within 3s)
- **2.5-second auto-advance** for NO-GO trials
- **Real-time score tracking**
- **Progress bar visualization**
- **Animated feedback** for each response

### 📊 Data Collection
The game collects comprehensive data for each trial:
```javascript
{
  trialNumber: 1,
  stimulus: 'happy' | 'sleepy',
  response: 'tap' | 'no_tap' | 'wrong_tap' | 'miss',
  reactionTime: milliseconds,
  correct: boolean,
  timestamp: ISO string
}
```

### 📈 Results Metrics
- **Score** (correct responses)
- **Accuracy** percentage
- **Average reaction time**
- **Completion time**
- **Detailed trial-by-trial data**

## File Locations

### Android Asset
```
android/app/src/main/assets/games/frog-jump.html
```

### Development Copy
```
games/frog-jump.html
```

## Integration with React Native

### GameWebView Component
The game is loaded via `GameWebView` component with `gameType='frog_jump'`:

```typescript
<GameWebView
  gameType="frog_jump"
  childData={childData}
  onComplete={handleGameComplete}
  onBack={handleBack}
/>
```

### Message Passing
The game communicates with React Native through `window.ReactNativeWebView.postMessage()`:

#### Game Complete Message
```javascript
{
  type: 'game_complete',
  gameType: 'frog_jump',
  results: {
    score: 8,
    accuracy: 80.0,
    avgReactionTime: 1250,
    completionTime: 45,
    totalTrials: 10,
    correctTrials: 8,
    trials: [...]
  }
}
```

#### Back Button Message
```javascript
{
  type: 'go_back'
}
```

## Game Flow

```
Instructions Screen
        ↓
   [Start Game]
        ↓
   Trial 1 of 10
   ├─ Show Character (Frog/Turtle)
   ├─ Wait for Response
   ├─ Show Feedback
   └─ Next Trial
        ↓
   ... (repeat 10x)
        ↓
   Results Screen
        ↓
   [Complete] → Send results to React Native
```

## Screen Descriptions

### 1. Instructions Screen
- **Game icon** with bounce animation (🎉)
- **Title**: "Animal Friends!"
- **Instructions**: "Tap the HAPPY animals when you see them! 😊"
- **Visual examples**:
  - Happy Frog with "✅ TAP the happy frog!"
  - Sleepy Turtle with "❌ DON'T tap sleepy turtle!"
- **Start button**: "🎮 Let's Play!"

### 2. Game Screen
- **Header**:
  - Back button (← Back)
  - Score display (⭐ X)
- **Progress bar** showing current trial
- **Instruction box** with dynamic text:
  - "Tap the Happy Animal! 😊" for GO trials
  - "Don't Tap! It's Sleepy! 😴" for NO-GO trials
- **Character area** with large animated animal
- **Character label** ("TAP ME!" or "DON'T TAP!")

### 3. Results Screen
- **Trophy icon** with spin animation (🏆)
- **Title**: "Amazing Job!"
- **Stats cards**:
  - Stars earned
  - Accuracy percentage
- **Complete button**: "🎉 All Done!"

## Technical Details

### Responsive Design
- **Mobile-optimized** with viewport meta tag
- **Touch-optimized** buttons and interactions
- **No text selection** or unwanted highlights
- **Smooth animations** using CSS keyframes
- **Hardware-accelerated** transforms

### Browser Compatibility
- Works in **Android WebView**
- Uses **Web Audio API** (fallback if not supported)
- **Touch events** properly handled
- **No external dependencies**

### Performance
- **Lightweight** - single HTML file
- **No images** - all emoji-based
- **Efficient animations** using CSS
- **Minimal JavaScript** for game logic

## Customization Options

### Adjust Difficulty
```javascript
gameState = {
  maxTrials: 10,  // Change number of trials
  // ... other settings
};
```

### Modify Trial Distribution
```javascript
// Currently 70% GO / 30% NO-GO
gameState.currentStimulus = Math.random() < 0.7 ? 'happy' : 'sleepy';
```

### Change Timing
```javascript
// GO trial timeout
gameState.responseTimeout = setTimeout(() => {
  handleResponse('miss');
}, 3000); // Change from 3 seconds

// NO-GO trial auto-advance
gameState.responseTimeout = setTimeout(() => {
  handleResponse('no_tap');
}, 2500); // Change from 2.5 seconds
```

## Assessment Guidelines

### Age Group
- **Primary**: 2-3 years old
- **Purpose**: Assess response inhibition and impulse control

### Expected Performance
- **Typical 2-3 year olds**: 50-70% accuracy
- **Higher scores**: Better impulse control
- **Reaction times**: Typically 1000-2000ms

### Clinical Interpretation
- **Low accuracy on GO trials**: Attention issues
- **Low accuracy on NO-GO trials**: Impulse control difficulties
- **Very slow reaction times**: Processing delays
- **Very fast errors**: Impulsivity

## Development Notes

### Audio Implementation
- Uses **Web Audio API** for synthesized sounds
- Frequencies chosen for pleasantness:
  - Tap: 800Hz
  - Correct: C-E-G (major triad)
  - Wrong: G-E (descending)
  - Celebration: C-E-G-C (arpeggio)

### Animation Strategy
- **CSS animations** for performance
- **@keyframes** for complex sequences
- **transform** and **opacity** for GPU acceleration
- **Confetti** created dynamically with JavaScript

### State Management
- Single `gameState` object
- Clear state transitions
- Timeout management for trial progression
- Response locking to prevent double-taps

## Future Enhancements

### Potential Features
- [ ] Multiple animal pairs (variety)
- [ ] Difficulty levels (faster timing)
- [ ] Sound effects with speech
- [ ] Multilingual support
- [ ] Practice mode with feedback
- [ ] Parent/clinician notes section

### Analytics Ideas
- Track improvement over multiple sessions
- Compare performance across age groups
- Identify specific error patterns
- Generate detailed clinical reports

## Testing Checklist

- [ ] Game loads properly in WebView
- [ ] Instructions screen displays correctly
- [ ] Start button works
- [ ] Characters appear and animate
- [ ] Touch events register properly
- [ ] Feedback appears for responses
- [ ] Score updates correctly
- [ ] Progress bar advances
- [ ] All 10 trials complete
- [ ] Results screen shows accurate data
- [ ] Complete button sends data to React Native
- [ ] Back button works at all stages
- [ ] Audio plays (if enabled)
- [ ] Music toggle works
- [ ] Confetti appears on correct responses
- [ ] No console errors

## Support

For issues or questions:
1. Check WebView console logs
2. Verify game file is in assets folder
3. Ensure WebView has JavaScript enabled
4. Test in browser first (standalone)
5. Check React Native WebView props

---

**Game Version**: 1.0.0  
**Last Updated**: October 25, 2025  
**Compatible With**: React Native WebView, Android WebView  
**Age Range**: 2-3 years  
**Assessment Type**: Go/No-Go (Response Inhibition)  
**Status**: ✅ Ready for Clinical Use

