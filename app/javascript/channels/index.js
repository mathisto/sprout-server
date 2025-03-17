// Import all the channels to be used by Action Cable
console.log("🔌 Loading channels/index.js")

try {
  import("./consumer").then(module => {
    console.log("✅ ActionCable consumer loaded")
    
    // Import plants channel
    import("./plants_channel").then(() => {
      console.log("✅ Plants channel loaded")
    }).catch(error => {
      console.error("❌ Error loading plants channel:", error)
    })
  }).catch(error => {
    console.error("❌ Error loading ActionCable consumer:", error)
  })
} catch (error) {
  console.error("❌ Error in channels/index.js:", error)
} 