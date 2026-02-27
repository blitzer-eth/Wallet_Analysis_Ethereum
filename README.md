# 📊 Ethereum Wallet Analysis

**[View Dashboard on Dune](https://dune.com/blitzer/gas-spend-calculator-ethereum)**

This dashboard provides a comprehensive technical and financial overview of any wallet on the **Ethereum Mainnet**. It is designed to transform complex on-chain data into actionable insights, focusing on high-value transactions, multi-standard activity, and long-term network engagement.

The dashboard uses a high-performance architecture to ensure that even "whale" wallets with thousands of transactions load efficiently. It provides a real-time view of portfolio health and activity levels using three core modules.

---

## :camera_flash: Snapshot 

<img width="3734" height="4839" alt="image" src="https://github.com/user-attachments/assets/47283490-c885-4659-9417-6874b486b18a" />

---

## 🔍 Query Breakdown

### 1. Gas Spend Counter

A dedicated financial tracker for network fees, essential for understanding the cost of maintaining an active presence on Ethereum.

* **Daily ETH Spend:** Tracks the total amount of ETH consumed by gas on a daily basis.
* **Cumulative Analysis:** Visualizes the lifetime cost of wallet operations.
* **Optimization:** Calculated by aggregating gas costs before applying window functions to minimize compute time.

### 2. Transaction Counter

A comprehensive monitor of the wallet's "on-chain footprint" across every major Ethereum interaction layer.

* **Layer Breakdown:** Segregates volume by Native Transactions, Internal Traces (Smart Contract calls), and Token Transfers.
* **Standard Coverage:** Automatically tracks ERC-20, ERC-721 (NFTs), and ERC-1155 (Single & Batch) events.
* **Optimization:** Built using a `UNION ALL` pattern instead of multiple `FULL OUTER JOINs`, allowing the query to scan each event table independently for maximum speed.

### 3. Top Interacted Counterparties

Identifies and ranks the most frequent relationships this wallet has established.

* **Interaction Ranking:** Displays the top 15 addresses by transaction count.
* **Financial Insight:** Tracks gas spent per counterparty and the timeframe of the relationship (First/Last Interaction).
* **UI Focus:** Features a "Short-Address" formatter (e.g., `0x123...abc`) and filtered logic to separate incoming vs. outgoing gas costs.
* **Optimization:** Splits the scan into two separate branches (Incoming vs. Outgoing) to allow the database to use native column indexes.

### 4. Daily and Total NFTs Sold

A volume-specific monitor for outbound digital assets.

* **Inventory Outflow:** Specifically counts how many NFTs (ERC-721 and ERC-1155) leave the wallet daily.
* **Sales Momentum:** Useful for tracking selling streaks and total lifetime inventory moved.

### 5. NFT Trade

Tracks the financial performance of NFT flips and acquisitions over time.

* **Gas Adjusted:** Accurately subtracts the specific gas cost of each transaction to reveal true net profit.
* **Multi-Asset:** Dynamically pulls minute-by-minute WETH price data to convert USD amounts back to their exact ETH value at the time of the trade.
* **Signed Flow:** Buy orders are displayed as negative values, while sales are positive.
