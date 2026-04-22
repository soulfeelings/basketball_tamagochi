import { test, expect } from '@playwright/test';

// Flutter web uses canvas rendering, so we interact via coordinates
// Viewport: 390x844 (iPhone-like)

test('Basketball Tamagochi - Full Game Flow', async ({ page }) => {
  // Enable Flutter semantics for accessibility
  await page.goto('/', { waitUntil: 'networkidle' });

  // Wait for Flutter to fully render
  await page.waitForTimeout(5000);

  // Screenshot 1: Create Player screen
  await page.screenshot({ path: 'results/01-create-player.png' });

  // Click on the "Player Name" text field (center of the input area)
  await page.click('flt-semantics input', { timeout: 3000 }).catch(async () => {
    // Fallback: click by coordinates where the text field is
    await page.mouse.click(195, 280);
  });
  await page.waitForTimeout(500);

  // Try typing via keyboard
  await page.keyboard.type('LeBron Jr', { delay: 100 });
  await page.waitForTimeout(1000);

  // Screenshot 2: Name entered
  await page.screenshot({ path: 'results/02-name-entered.png' });

  // Click "Shooting Guard" chip (approximate position)
  await page.mouse.click(420, 400);
  await page.waitForTimeout(500);

  // Screenshot 3: Position selected
  await page.screenshot({ path: 'results/03-position-selected.png' });

  // Click "START CAREER" button (bottom of screen)
  await page.mouse.click(195, 800);
  await page.waitForTimeout(3000);

  // Screenshot 4: Home screen (or still on create if typing didn't work)
  await page.screenshot({ path: 'results/04-after-start.png' });

  // Click "TRAIN" button (left side, middle area)
  await page.mouse.click(120, 520);
  await page.waitForTimeout(2000);

  // Screenshot 5: Training screen
  await page.screenshot({ path: 'results/05-training.png' });

  // Click "Shooting" to train
  await page.mouse.click(195, 250);
  await page.waitForTimeout(1500);

  // Screenshot 6: After training
  await page.screenshot({ path: 'results/06-after-training.png' });

  // Click "Dribbling" to train
  await page.mouse.click(195, 320);
  await page.waitForTimeout(1500);

  // Click "Defense" to train
  await page.mouse.click(195, 390);
  await page.waitForTimeout(1500);

  // Screenshot 7: After more training
  await page.screenshot({ path: 'results/07-more-training.png' });

  // Go back (click back arrow top-left)
  await page.mouse.click(30, 40);
  await page.waitForTimeout(2000);

  // Screenshot 8: Home after training
  await page.screenshot({ path: 'results/08-home-after-training.png' });

  // Click "PLAY MATCH" button (right side)
  await page.mouse.click(290, 520);
  await page.waitForTimeout(2000);

  // Screenshot 9: Match screen
  await page.screenshot({ path: 'results/09-match-screen.png' });

  // Click "START MATCH"
  await page.mouse.click(195, 600);
  await page.waitForTimeout(3000);

  // Screenshot 10: Match result
  await page.screenshot({ path: 'results/10-match-result.png' });

  // Scroll down to see full log
  await page.mouse.wheel(0, 300);
  await page.waitForTimeout(1000);

  // Screenshot 11: Match log
  await page.screenshot({ path: 'results/11-match-log.png' });
});
