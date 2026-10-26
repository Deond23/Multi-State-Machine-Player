# Multistate Machine Player 

A Godot project featuring a player controller that uses independent movement and combat state machines to determine behavior. 

## Features 
- Separate movement and combat state machines 
- State-based player controller architecture 
- Health and stamina systems 

Movement states include walking, jumping, rolling, and climbing. Combat states include attacking, blocking, and parrying. 

## Purpose 
As the number of player actions grows, managing behavior through nested conditional statements can lead to large, difficult-to-maintain controller scripts. 
This project addresses that problem by separating movement and combat behavior into independent state machines. 
Each state encapsulates its own behavior while sharing common functionality through a central player script, resulting in a more organized and extensible architecture.
