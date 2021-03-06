This is a fork with modifications.
==================================
Modifications:

* Oct 27, 2011: 
  * Exposed the Font Texture property in SPBitmapFont
  * Added a class method to SPTextField to find registered BitmapFonts for use outside of SPTextFields. 
* Oct 10, 2011: Overwrote SHClippedSprite's removeAllChildren to not remove mClip.
* Shilo's [SHThumbstick Extension](http://wiki.sparrow-framework.org/users/shilo/extensions/shthumbstick)
* Shilo's [SHSwipeEvent Extension](http://wiki.sparrow-framework.org/users/shilo/extensions/shswipeevent)
* Daniel's [SXGauge Extension](http://wiki.sparrow-framework.org/extensions/gauge)
* BodSix's BSMovieClipAtlas for configuring an library of animations you want to load by name.
* Modifications to SPDisplayObject
  * promotion of removeChild and dispatchEventOnChildren which were previously internal methods
  * addition of sortChildrenUsingComparator, which passes an NSComparator tothe underlying mChildren's sortUsingComparator method.
* Modifications to SPMovieClip
  * exposed currentTime as a read-only property
* Modifications to SPPooledObject
  * only allow objects allocated/deallocated in the main thread be eligible
    to pull from or add to the pool.
* Shilo's [SHClippedSprite Extension](http://wiki.sparrow-framework.org/users/shilo/extensions/shclippedsprite)

Sparrow: an Open Source Framework for iPhone game development 
=============================================================

What is Sparrow?
----------------
 
Sparrow is a pure Objective C library targeted on making game development as easy and hassle-free
as possible. Sparrow makes it possible to write fast OpenGL applications without having to touch
OpenGL or pure C (but easily allowing to do so, for those who wish). It uses a tried and tested
API that is easy to use and hard to misuse.
 
Who is Sparrow for?
-------------------
 
Obviously, Sparrow is for iPhone and iPad developers, especially those involved in game development.
You will need to have a basic understanding of Objective-C – but there’s no way around that on the
iOS anyway.

If you have already worked with Adobe Flash/Flex technology, you will immediately befriend with
Sparrow since it uses lots of similar concepts and naming schemes. That said, everything is
designed to be as intuitive as possible, so any Java or .Net� developer will get the hang of it
quickly as well.

How to start?
-------------

* Read through the file 'BUILDING.markdown' for a quick start with Sparrow.
* Visit <http://www.sparrow-framework.org>
