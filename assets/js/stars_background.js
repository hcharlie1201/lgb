import * as THREE from 'three';
import { Hook, makeHook } from "phoenix_typed_hook"
class StarsBackground extends Hook {
    mounted() {
        try {
            // Create scene, camera, and renderer
            this.scene = new THREE.Scene();

            this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            this.camera.position.z = 1;

            // Create renderer with alpha channel
            this.renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
            this.renderer.setSize(window.innerWidth, window.innerHeight);
            this.renderer.setClearColor(0x000000, 0); // Transparent background
            this.el.appendChild(this.renderer.domElement);

            // Create two different star groups rotating in opposite directions
            this.createStars();
            this.createStarsOpposite();

            // Handle window resize
            this.handleResize = () => {
                this.camera.aspect = window.innerWidth / window.innerHeight;
                this.camera.updateProjectionMatrix();
                this.renderer.setSize(window.innerWidth, window.innerHeight);
            };

            window.addEventListener('resize', this.handleResize);

            // Start animation loop
            this.animationFrame = null;
            this.lastTime = null;
            this.animate();
        } catch (error) {
            console.error("Error initializing Three.js stars:", error);
        }
    }

    createStars() {
        try {
            // Define a color palette (blues and purples)
            const colorPalette = [
                [0.23, 0.11, 0.92], // Purple
                [0.46, 0.11, 0.92], // Violet
                [0.58, 0.29, 0.94], // Lavender
                [0.27, 0.51, 0.93], // Blue
                [0.83, 0.11, 0.92], // Pink-purple
                [0.13, 0.59, 0.95], // Azure blue
                [0.99, 0.20, 0.80], // Hot pink
                [1.00, 0.25, 0.50], // Deep pink
                [1.00, 0.35, 0.20], // Red-orange
                [0.95, 0.45, 0.30]  // Lighter orange-red
            ];

            const starCount = 300;
            const starGroup = new THREE.Group(); // Create a group to hold all the stars

            // Improve lighting for better face visibility
            const ambientLight = new THREE.AmbientLight(0xffffff, 27); // Brighter ambient light
            this.scene.add(ambientLight);

            // Add directional lights from multiple angles to highlight faces
            const directionalLight1 = new THREE.DirectionalLight(0xffffff, 0.5);
            directionalLight1.position.set(1, 1, 1);
            this.scene.add(directionalLight1);

            const directionalLight2 = new THREE.DirectionalLight(0xffffff, 0.5);
            directionalLight2.position.set(-1, -1, -1);
            this.scene.add(directionalLight2);

            // Add point lights for color
            const pointLight1 = new THREE.PointLight(0xffffff, 0.2, 100);
            pointLight1.position.set(10, 10, 10);
            this.scene.add(pointLight1);

            const pointLight2 = new THREE.PointLight(0xffffff, 0.5, 100);
            pointLight2.position.set(-10, 5, -10);
            this.scene.add(pointLight2);

            // Store references to the lights for animation
            this.lights = [directionalLight1, directionalLight2, pointLight1, pointLight2];

            // Create a variety of star sizes
            const sizeTiers = [0.003, 0.004, 0.005]; // Small, medium, large
            const sizeWeights = [0.7, 0.6, 0.5]; // 70% small, 20% medium, 10% large

            // Function to select star size based on weighted distribution
            const selectStarSize = () => {
                const rand = Math.random();
                let cumulativeWeight = 0;

                for (let i = 0; i < sizeTiers.length; i++) {
                    cumulativeWeight += sizeWeights[i];
                    if (rand < cumulativeWeight) {
                        return sizeTiers[i];
                    }
                }
                return sizeTiers[0]; // Default fallback
            };

            for (let i = 0; i < starCount; i++) {
                // Create a dodecahedron geometry with varying sizes
                const starSize = selectStarSize();
                const starGeometry = new THREE.DodecahedronGeometry(starSize, 0);

                // Assign a random color from our palette
                const randomColor = colorPalette[Math.floor(Math.random() * colorPalette.length)];

                // Use MeshStandardMaterial for better metallic look
                const starMaterial = new THREE.MeshStandardMaterial({
                    color: new THREE.Color(randomColor[0], randomColor[1], randomColor[2]),
                    emissive: new THREE.Color(randomColor[0] * 0.1, randomColor[1] * 0.1, randomColor[2] * 0.1),
                    metalness: 0.8,      // High metalness
                    roughness: 0.2,      // Low roughness for shiny metal
                    flatShading: true,   // Emphasize the faces
                    transparent: true,
                    opacity: 0.9
                });

                // Create a mesh for the star
                const starMesh = new THREE.Mesh(starGeometry, starMaterial);

                // Add subtle edge highlighting with wireframe
                const wireframeGeometry = new THREE.WireframeGeometry(starGeometry);
                const wireframeMaterial = new THREE.LineBasicMaterial({
                    color: new THREE.Color(randomColor[0] + 0.2, randomColor[1] + 0.2, randomColor[2] + 0.2),
                    transparent: true,
                    opacity: 0.3
                });
                const wireframe = new THREE.LineSegments(wireframeGeometry, wireframeMaterial);
                starMesh.add(wireframe);

                // Position the star randomly in a sphere
                const radius = Math.pow(Math.random(), 0.5) * 0.8 + 0.7;
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.acos(2 * Math.random() - 1);

                starMesh.position.set(
                    radius * Math.sin(phi) * Math.cos(theta),
                    radius * Math.sin(phi) * Math.sin(theta),
                    radius * Math.cos(phi)
                );

                // Add some random rotation to each dodecahedron for variety
                starMesh.rotation.set(
                    Math.random() * Math.PI * 2,
                    Math.random() * Math.PI * 2,
                    Math.random() * Math.PI * 2
                );

                // Store the original position and rotation speed for animation
                starMesh.userData = {
                    originalPosition: starMesh.position.clone(),
                    rotationSpeed: {
                        x: (Math.random() - 0.5) * 0.004, // Slower rotation
                        y: (Math.random() - 0.5) * 0.004,
                        z: (Math.random() - 0.5) * 0.004
                    },
                    pulseSpeed: Math.random() * 0.01 + 0.005, // Slower pulsing
                    pulseOffset: Math.random() * Math.PI * 2
                };

                // Add the star to the group
                starGroup.add(starMesh);
            }

            // Add the group of stars to the scene
            this.stars = starGroup;
            this.scene.add(this.stars);

            // Set initial rotation for the entire group
            this.stars.rotation.set(0, 0, Math.PI / 4);
        } catch (error) {
            console.error("Error creating first star group:", error);
        }
    }

    createStarsOpposite() {
        try {
            // Define a color palette (blues and purples)
            const colorPalette = [
                [0.23, 0.11, 0.92], // Purple
                [0.46, 0.11, 0.92], // Violet
                [0.58, 0.29, 0.94], // Lavender
                [0.27, 0.51, 0.93], // Blue
                [0.28, 0.78, 0.94], // Light blue
                [0.83, 0.11, 0.92], // Pink-purple
                [0.53, 0.81, 0.98], // Sky blue
                [0.13, 0.59, 0.95], // Azure blue
                [1.00, 0.41, 0.71], // Pink
                [0.99, 0.20, 0.80], // Hot pink
                [1.00, 0.25, 0.50], // Deep pink
                [1.00, 0.35, 0.20], // Red-orange
                [0.95, 0.45, 0.30]  // Lighter orange-red
            ];

            const starCount = 300;
            const starGroup = new THREE.Group(); // Create a group to hold all the stars

            const sizeTiers = [0.003, 0.004, 0.005]; // Small, medium, large
            const sizeWeights = [0.7, 0.6, 0.5]; // 70% small, 20% medium, 10% large

            // Function to select star size based on weighted distribution
            const selectStarSize = () => {
                const rand = Math.random();
                let cumulativeWeight = 0;

                for (let i = 0; i < sizeTiers.length; i++) {
                    cumulativeWeight += sizeWeights[i];
                    if (rand < cumulativeWeight) {
                        return sizeTiers[i];
                    }
                }
                return sizeTiers[0]; // Default fallback
            };

            for (let i = 0; i < starCount; i++) {
                // Create a dodecahedron geometry with varying sizes
                const starSize = selectStarSize();
                const starGeometry = new THREE.DodecahedronGeometry(starSize, 0);

                // Assign a random color from our palette
                const randomColor = colorPalette[Math.floor(Math.random() * colorPalette.length)];

                // Use MeshStandardMaterial for better metallic look
                const starMaterial = new THREE.MeshStandardMaterial({
                    color: new THREE.Color(randomColor[0], randomColor[1], randomColor[2]),
                    emissive: new THREE.Color(randomColor[0] * 0.1, randomColor[1] * 0.1, randomColor[2] * 0.1),
                    metalness: 0.8,      // High metalness
                    roughness: 0.2,      // Low roughness for shiny metal
                    flatShading: true,   // Emphasize the faces
                    transparent: true,
                    opacity: 0.3
                });

                // Create a mesh for the star
                const starMesh = new THREE.Mesh(starGeometry, starMaterial);

                // Add subtle edge highlighting with wireframe
                const wireframeGeometry = new THREE.WireframeGeometry(starGeometry);
                const wireframeMaterial = new THREE.LineBasicMaterial({
                    color: new THREE.Color(randomColor[0] + 0.2, randomColor[1] + 0.2, randomColor[2] + 0.2),
                    transparent: true,
                    opacity: 0.3
                });
                const wireframe = new THREE.LineSegments(wireframeGeometry, wireframeMaterial);
                starMesh.add(wireframe);

                // Position the star randomly in a sphere, but further out
                const radius = Math.pow(Math.random(), 0.5) * 0.8 + 1.2; // Further out
                const theta = Math.random() * Math.PI * 2;
                const phi = Math.acos(2 * Math.random() - 1);

                starMesh.position.set(
                    radius * Math.sin(phi) * Math.cos(theta),
                    radius * Math.sin(phi) * Math.sin(theta),
                    radius * Math.cos(phi)
                );

                // Add some random rotation to each dodecahedron for variety
                starMesh.rotation.set(
                    Math.random() * Math.PI * 2,
                    Math.random() * Math.PI * 2,
                    Math.random() * Math.PI * 2
                );

                // Store the original position and rotation speed for animation
                starMesh.userData = {
                    originalPosition: starMesh.position.clone(),
                    rotationSpeed: {
                        x: (Math.random() - 0.5) * 0.004,
                        y: (Math.random() - 0.5) * 0.004,
                        z: (Math.random() - 0.5) * 0.004
                    },
                    pulseSpeed: Math.random() * 0.01 + 0.005,
                    pulseOffset: Math.random() * Math.PI * 2
                };

                // Add the star to the group
                starGroup.add(starMesh);
            }

            // Add the group of stars to the scene
            this.starsOpposite = starGroup; // Store in a different property
            this.scene.add(this.starsOpposite);

            // Set initial rotation for the entire group
            this.starsOpposite.rotation.set(0, 0, -Math.PI / 4); // Different initial rotation
        } catch (error) {
            console.error("Error creating second star group:", error);
        }
    }

    animate() {
        try {
            this.animationFrame = requestAnimationFrame(this.animate.bind(this));

            // Get delta time
            const currentTime = Date.now() * 0.001;
            if (!this.lastTime) this.lastTime = currentTime;
            const delta = currentTime - this.lastTime;
            this.lastTime = currentTime;

            // First star group rotating one way
            if (this.stars) {
                this.stars.rotation.x -= delta / 15;
                this.stars.rotation.y -= delta / 20;

                // Individual star rotation in first group
                this.stars.children.forEach(star => {
                    star.rotation.x += star.userData.rotationSpeed.x * 0.3;
                    star.rotation.y += star.userData.rotationSpeed.y * 0.3;
                    star.rotation.z += star.userData.rotationSpeed.z * 0.3;

                    const scale = 1 + 0.05 * Math.sin(currentTime * star.userData.pulseSpeed + star.userData.pulseOffset);
                    star.scale.set(scale, scale, scale);
                });
            }

            // Second star group rotating the opposite way
            if (this.starsOpposite) {
                this.starsOpposite.rotation.x += delta / 15; // Opposite direction
                this.starsOpposite.rotation.y += delta / 20; // Opposite direction

                // Individual star rotation in second group
                this.starsOpposite.children.forEach(star => {
                    star.rotation.x -= star.userData.rotationSpeed.x * 0.3; // Opposite direction
                    star.rotation.y -= star.userData.rotationSpeed.y * 0.3; // Opposite direction
                    star.rotation.z -= star.userData.rotationSpeed.z * 0.3; // Opposite direction

                    const scale = 1 + 0.05 * Math.sin(currentTime * star.userData.pulseSpeed + star.userData.pulseOffset);
                    star.scale.set(scale, scale, scale);
                });
            }

            // Animate point lights for dynamic lighting
            if (this.lights) {
                // Make first point light orbit slowly
                this.lights[2].position.x = Math.sin(currentTime * 0.15) * 10;
                this.lights[2].position.z = Math.cos(currentTime * 0.15) * 10;

                // Make second point light move up and down slowly
                this.lights[3].position.y = 5 + Math.sin(currentTime * 0.25) * 5;
            }

            this.renderer.render(this.scene, this.camera);
        } catch (error) {
            console.error("Error in animation loop:", error);
            cancelAnimationFrame(this.animationFrame);
        }
    }

    destroyed() {
        // Clean up
        cancelAnimationFrame(this.animationFrame);
        window.removeEventListener('resize', this.handleResize);

        if (this.renderer) {
            this.renderer.dispose();
        }

        this.scene = null;
        this.camera = null;
        this.stars = null;
        this.starsOpposite = null;
        this.lights = null;
        this.renderer = null;
    }
}


export default makeHook(StarsBackground);