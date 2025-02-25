defmodule LgbWeb.BlogsLive.Strategy do
  use LgbWeb, :live_view

  # Render function
  def render(assigns) do
    ~H"""
    <.blog>
      <div class="font-sans min-h-screen">
        <div class="container mx-auto px-4 py-10">
          <h1 class="mb-8 text-center text-4xl text-gray-800">
            Finding Connection: The Story Behind BiBi
          </h1>

          <section class="mb-10 transition-shadow transition-transform duration-300 hover:translate-y-[-5px] hover:shadow-lg">
            <h2 class="mb-6 text-3xl text-gray-700">The Hidden Isolation of Bisexuality</h2>
            <p class="mb-4 text-lg leading-relaxed text-gray-600">
              San Francisco and North Carolina might seem worlds apart, but they share a common thread—the challenge of finding genuine community, especially for those navigating the complex landscape of bisexual identity.
            </p>
            <p class="text-lg leading-relaxed text-gray-600">
              I've watched countless friends struggle—brilliant, compassionate individuals who felt perpetually caught between worlds. Not quite fitting into traditional dating apps, not fully seen in LGBTQ+ spaces, and often misunderstood by both straight and gay communities.
            </p>
          </section>

          <section class="mb-10 rounded-lg bg-gradient-to-br from-blue-50 to-gray-100 p-8 shadow-lg transition-shadow duration-300 hover:shadow-2xl">
            <h2 class="mb-6 text-3xl text-gray-700">The Invisible Middle Ground</h2>
            <p class="mb-4 text-lg leading-relaxed text-gray-600">
              Bisexuality isn't a stopover or a phase. It's a rich, nuanced identity that deserves recognition, respect, and dedicated spaces for connection.
            </p>
            <ul class="list-inside list-disc space-y-3 text-lg text-gray-600">
              <li>
                Dating apps that force users into rigid, binary categories, erasing the nuances of bisexual attraction.
              </li>
              <li>Communities that question the validity of their attraction.</li>
              <li>The constant emotional labor of explaining their identity.</li>
            </ul>
          </section>

          <section class="mb-10">
            <h2 class="mb-6 text-3xl text-gray-700">More Than Just a Dating App</h2>
            <p class="mb-4 text-lg leading-relaxed text-gray-600">
              This isn't just about romantic connections. It's about building a supportive ecosystem where:
            </p>
            <ul class="list-inside list-disc space-y-3 text-lg text-gray-600">
              <li>Bisexual individuals can be fully themselves.</li>
              <li>Conversations go beyond surface-level interactions.</li>
              <li>
                Shared experiences create meaningful connections through group events and community forums.
              </li>
              <li>
                Have in person events in a secure community
              </li>
            </ul>
          </section>

          <section class="mb-10 rounded-lg bg-gradient-to-br from-indigo-50 to-blue-100 p-8 shadow-lg transition-shadow duration-300 hover:shadow-2xl">
            <h2 class="mb-6 text-3xl text-gray-700">The Spark of Innovation</h2>
            <p class="mb-4 text-lg leading-relaxed text-gray-600">
              Every great product starts with empathy. By listening to the struggles of my bisexual friends, I realized we needed more than just another dating platform. We needed a community builder, a safe haven that celebrates the complexity of human attraction. Thus we are building in features like location based groups, and user driven forums.
            </p>

            <div class="rounded-lg bg-white p-6 shadow-md">
              <h3 class="mb-4 text-2xl text-gray-800">Our Core Values</h3>
              <ol class="list-inside list-decimal space-y-3 text-lg text-gray-600">
                <li><strong>Authenticity</strong>: Embrace diverse identities.</li>
                <li><strong>Safety</strong>: Robust privacy and consent mechanisms.</li>
                <li>
                  <strong>Community</strong>: Fostering connections beyond romantic relationships.
                </li>
                <li><strong>Education</strong>: Resources and support for understanding identity.</li>
              </ol>
            </div>
          </section>

          <section class="py-8 text-center">
            <h2 class="mb-4 text-2xl text-gray-800">The Journey Continues</h2>
            <p class="mb-6 text-lg text-gray-600">
              This app is more than a tool; it's a space for authentic connection.
            </p>
            <a
              href={~p"/users/log_in"}
              class="rounded bg-indigo-600 px-6 py-3 text-white transition-colors duration-200 hover:bg-indigo-700"
            >
              Join Us
            </a>
          </section>
        </div>
      </div>
    </.blog>
    """
  end
end
