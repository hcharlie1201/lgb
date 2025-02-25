defmodule LgbWeb.BlogsLive.Marketing do
  use LgbWeb, :live_view

  # Render function
  def render(assigns) do
    ~H"""
    <.blog>
      <h1 class="mb-8 text-center text-4xl font-bold text-gray-800">
        Marketing BiBi: Building a Community
      </h1>

      <section class="mb-10">
        <h2 class="mb-6 text-3xl text-gray-700">Storytelling Through Short Films</h2>
        <p class="mb-4 text-lg leading-relaxed text-gray-600">
          We believe in the power of stories. To authentically connect with our community, we'll produce a series of short films that capture the diverse experiences of bisexual individuals. These films will go beyond surface-level narratives, exploring the nuances of identity, connection, and belonging.
        </p>
        <p class="text-lg leading-relaxed text-gray-600">
          Our goal is to create content that resonates deeply, fostering empathy and understanding. These films will be shared across our platforms, sparking conversations and building a strong emotional connection with our audience.
        </p>
      </section>

      <section class="mb-10 rounded-lg bg-gradient-to-br from-blue-50 to-gray-100 p-8 shadow-lg transition-shadow duration-300 hover:shadow-2xl">
        <h2 class="mb-6 text-3xl text-gray-700">Growing Our Presence on Instagram and TikTok</h2>
        <p class="mb-4 text-lg leading-relaxed text-gray-600">
          In today's digital landscape, Instagram and TikTok are vital platforms for reaching and engaging with our target audience. We'll leverage these platforms to create a vibrant and inclusive online community.
        </p>
        <ul class="list-inside list-disc space-y-3 text-lg text-gray-600">
          <li>
            <strong>Engaging Content:</strong>
            We'll create visually compelling content, including short-form videos, user-generated stories, and behind-the-scenes glimpses into our community.
          </li>
          <li>
            <strong>Interactive Campaigns:</strong>
            We'll run interactive campaigns, such as Q&A sessions, polls, and challenges, to encourage user participation and build a sense of belonging.
          </li>
          <li>
            <strong>Strategic Partnerships:</strong>
            We'll collaborate with influencers and organizations within the LGBTQ+ community to expand our reach and amplify our message.
          </li>
          <li>
            <strong>Authentic Voice:</strong>
            We'll maintain an authentic and relatable voice, fostering genuine connections with our followers.
          </li>
        </ul>
      </section>

      <section class="mb-10">
        <h2 class="mb-6 text-3xl text-gray-700">Community-Driven Marketing</h2>
        <p class="mb-4 text-lg leading-relaxed text-gray-600">
          We believe that our community is our greatest asset. We'll actively involve our users in our marketing efforts, encouraging them to share their stories and experiences.
        </p>
        <ul class="list-inside list-disc space-y-3 text-lg text-gray-600">
          <li>
            <strong>User-Generated Content:</strong>
            We'll feature user-generated content on our platforms, showcasing the diversity and authenticity of our community.
          </li>
          <li>
            <strong>Feedback and Input:</strong>
            We'll actively seek feedback from our users, incorporating their input into our marketing strategies.
          </li>
          <li>
            <strong>Community Events:</strong>
            We'll organize online and offline events to foster connections and build a strong sense of community.
          </li>
        </ul>
      </section>

      <section class="py-8 text-center">
        <h2 class="mb-4 text-2xl text-gray-800">Join Our Journey</h2>
        <p class="mb-6 text-lg text-gray-600">
          We're committed to building a platform that truly serves the bisexual community. Join us as we create a space for authentic connection and celebration.
        </p>
        <a
          href="#"
          class="rounded bg-indigo-600 px-6 py-3 text-white transition-colors duration-200 hover:bg-indigo-700"
        >
          Follow Us
        </a>
      </section>
    </.blog>
    """
  end
end
