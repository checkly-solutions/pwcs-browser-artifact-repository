import { test, expect } from '@playwright/test'

test('homepage has title', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveTitle(/Danube/)
})

test('homepage has products', async ({ page }) => {
  await page.goto('/')
  const products = page.locator('.shop-content .preview')
  await expect(products.first()).toBeVisible()
})
