# frozen_string_literal: true

Chartkick.options = {
  height: "400px",
  colors: ["#667eea", "#764ba2", "#f093fb", "#4facfe"],
  library: {
    backgroundColor: "#ffffff",
    maintainAspectRatio: true,
    responsive: true,
    plugins: {
      legend: {
        display: true,
        position: "bottom"
      }
    }
  }
}
